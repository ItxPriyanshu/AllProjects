import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/doctor/doctorHome/consultation_form_popup.dart';
import 'package:frontend/patient/providers/auth_provider.dart';
import 'package:frontend/start_page.dart';
import 'package:frontend/patient/services/video_call_api.dart';

/// Unified consultation response screen for BOTH patient and doctor.
///
/// [isDoctor] = false (default) → patient view:
///   shows doctor response/prescription; emergency shows call & video buttons.
///
/// [isDoctor] = true → doctor view:
///   shows patient form (expandable), notes text field, prescription upload, submit.
class PatientConsultationChatScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String doctorName;
  final String doctorSpeciality;
  final bool isEmergency;
  /// Set to true when the doctor is viewing this screen.
  final bool isDoctor;

  const PatientConsultationChatScreen({
    super.key,
    required this.consultationId,
    this.doctorName = 'Doctor',
    this.doctorSpeciality = 'General',
    required this.isEmergency,
    this.isDoctor = false,
  });

  @override
  ConsumerState<PatientConsultationChatScreen> createState() =>
      _PatientConsultationChatScreenState();
}

class _PatientConsultationChatScreenState
    extends ConsumerState<PatientConsultationChatScreen>
    with RouteAware, WidgetsBindingObserver {
  // ── Colours
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color darkBg = Color(0xFF0F0024);
  static const Color surface = Color(0xFF1A0F32);
  static const Color kEmergency = Color(0xFFFF4C6A);
  static const Color kNormal = Color(0xFF00D4AA);
  static const Color kAccentBright = Color(0xFF3D40CC);

  final ApiService _api = ApiService();

  // ── Shared state
  bool _loading = true;
  Map<String, dynamic>? _consultation;

  // ── Patient-side state 
  bool _callLoading = false;
  bool _videoLoading = false;

  // ── Doctor-side state
  bool _formExpanded = false;
  final _notesCtrl = TextEditingController();
  String? _prescriptionFileName;
  List<int>? _prescriptionBytes;
  bool _isSubmitting = false;

  // ──────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchConsultation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _fetchConsultation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _fetchConsultation();
    }
  }

  // ── Data fetch 

  Future<void> _fetchConsultation() async {
    try {
      final token = await TokenStorage.getToken();
      final endpoint = widget.isDoctor
          ? '/doctor/showform/${widget.consultationId}'
          : '/patient/showform/${widget.consultationId}';
      final res = await _api.get(endpoint, token: token);
      if (mounted) {
        setState(() {
          // Doctor endpoint returns the doc directly; patient wraps in 'full'
          if (res is Map<String, dynamic>) {
            _consultation = res['full'] as Map<String, dynamic>? ?? res;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  // ── Doctor actions 

  Future<void> _pickPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes == null) return;
    setState(() {
      _prescriptionFileName = file.name;
      _prescriptionBytes = file.bytes;
    });
  }

  Future<void> _submitDoctorResponse() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final token = await TokenStorage.getToken();
      final res = await _api.postForm(
        '/doctor/form/${widget.consultationId}',
        {'textResponse': _notesCtrl.text.trim()},
        token: token,
        fileBytes: _prescriptionBytes,
        fileName: _prescriptionFileName ?? 'prescription',
        fileFieldName: 'doctorAnswer',
      );
      final updated = res['response'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          if (updated != null) _consultation = updated;
        });
        _showSnack('Response submitted successfully!');
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Patient actions 

  Future<void> _handleCall() async {
    setState(() => _callLoading = true);
    try {
      final token = await TokenStorage.getToken();
      final res = await _api.get(
        '/patient/emergency/masked/${widget.consultationId}',
        token: token,
      );
      final number = res['maskedNumber'] as String?;
      if (number == null || number.isEmpty) {
        _showSnack('Doctor number unavailable. Try again later.', error: true);
        setState(() => _callLoading = false);
        return;
      }
      
      // Show masked number dialog before calling
      if (mounted) {
        _showMaskedNumberDialog(number);
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _callLoading = false);
    }
  }

  void _showMaskedNumberDialog(String maskedNumber) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Call Doctor',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your call will be connected via a masked number for privacy.',
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF080826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1D1F8C).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    'Doctor\'s Masked Number',
                    style: GoogleFonts.manrope(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    maskedNumber,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1D1F8C),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri(scheme: 'tel', path: maskedNumber);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                _showSnack('Opening phone dialer...');
              } else {
                _showSnack('Could not launch phone dialer.', error: true);
              }
            },
            icon: const Icon(Icons.call_rounded, color: Colors.white),
            label: Text(
              'Call Now',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4C6A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVideoCall() async {
    setState(() => _videoLoading = true);
    try {
      final String doctorId =
          (_consultation?['doctor_id'] is Map)
              ? (_consultation!['doctor_id'] as Map)['_id']?.toString() ?? ''
              : _consultation?['doctor_id']?.toString() ?? '';

      if (doctorId.isEmpty) {
        _showSnack('Doctor ID not found. Cannot launch video call.', error: true);
        return;
      }

      // Show loading indicator with message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Preparing video call...'),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.grey.shade700,
          ),
        );
      }

      // Request video call (with FCM notification + direct Jitsi link)
      await VideoCallApi.requestVideoCall(doctorId, widget.consultationId);

      if (mounted) {
        _showSnack('Video call launched! Check your browser.');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      
      if (mounted) {
        // Show detailed error with suggestions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A0F32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Video Call Error',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              errorMsg,
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(color: const Color(0xFF1D1F8C)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleVideoCall(); // Retry
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D1F8C),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _videoLoading = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  // ── Build 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D1F8C)))
          : widget.isDoctor
              ? _buildDoctorView()
              : _buildPatientView(),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isDoctor
              ? 'Patient Consultation'
              : (widget.isEmergency
                  ? 'Emergency Consultation'
                  : 'Consultation Submitted'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      );

  // ══════════════════════
  // LOGOUT HANDLER
  // ═══════════════════════

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Call logout through provider
        await ref.read(authProvider.notifier).logout();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const StartPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout error: $e')),
          );
        }
      }
    }
  }

  // ══════════════════════
  // PATIENT VIEW
  // ═════════════════════

  Widget _buildPatientView() {
    final c = _consultation;
    final status = c?['status'] as String? ?? 'pending';
    final responded = status == 'responded';
    final doctorFileUrl = c?['doctorFileUrl'] as String?;
    final doctorNotes = (c?['doctorTextResponse'] ?? c?['doctorNotes']) as String?;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Doctor header card
            _doctorHeaderCard(),
            const SizedBox(height: 16),

            // ── Status banner 
            _statusBanner(responded),
            const SizedBox(height: 20),

            // ── Emergency actions (patient only, emergency only) 
            if (widget.isEmergency) ...[
              Text('Emergency Actions',
                  style: GoogleFonts.poppins(
                      color: kEmergency,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _callButton()),
                const SizedBox(width: 12),
                Expanded(child: _videoButton()),
              ]),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Call connects via a masked number. Video opens in your browser.',
                  style:
                      GoogleFonts.manrope(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Doctor response section 
            if (responded)
              _buildDoctorResponseSection(
                doctorNotes: doctorNotes,
                doctorFileUrl: doctorFileUrl,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _doctorHeaderCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            child: Text(
              widget.doctorName.isNotEmpty
                  ? widget.doctorName[0].toUpperCase()
                  : 'D',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                Text(widget.doctorSpeciality,
                    style:
                        GoogleFonts.manrope(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _typeBadge(widget.isEmergency),
        ]),
      );

  Widget _typeBadge(bool emergency) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (emergency ? kEmergency : kNormal).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: emergency ? kEmergency : kNormal),
        ),
        child: Text(
          emergency ? 'Emergency' : 'Normal',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: emergency ? kEmergency : kNormal,
          ),
        ),
      );

  Widget _statusBanner(bool responded) {
    final color = responded ? kNormal : const Color(0xFFFFA726);
    final icon =
        responded ? Icons.check_circle : Icons.hourglass_top_rounded;
    final title =
        responded ? 'Doctor has responded!' : 'Consultation submitted';
    final sub = responded
        ? 'Your prescription and notes are ready below.'
        : 'Your form has been sent to the doctor. You can track the response here.';
    
    return GestureDetector(
      onTap: () => showConsultationFormPopup(
        context,
        consultationId: widget.consultationId,
        isDoctor: widget.isDoctor,
        doctorName: widget.doctorName,
        doctorSpeciality: widget.doctorSpeciality,
        isEmergency: widget.isEmergency,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(sub,
                    style:
                        GoogleFonts.manrope(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _callButton() => ElevatedButton.icon(
        onPressed: _callLoading ? null : _handleCall,
        icon: _callLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.call_rounded, color: Colors.white),
        label: Text('Call Doctor',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: kEmergency,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _videoButton() => ElevatedButton.icon(
        onPressed: _videoLoading ? null : _handleVideoCall,
        icon: _videoLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.videocam_rounded, color: Colors.white),
        label: Text('Video Call',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B2FBE),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  // ════════════════════════════
  // DOCTOR VIEW
  // ════════════════════════════

  Widget _buildDoctorView() {
    final c = _consultation;
    final patientName = c?['full_name'] as String? ?? 'Patient';
    final age = c?['age'] as String? ?? '-';
    final gender = c?['gender'] as String? ?? '-';
    final problem = c?['Problem'] as String? ?? 'Not specified';
    final patientFileUrl = c?['patientFileUrl'] as String?;
    final type = c?['type'] as String? ?? 'normal';
    final status = c?['status'] as String? ?? 'pending';
    final isEmerg = type == 'emergency';
    final alreadyResponded = status == 'responded';
    
    // Doctor response fields
    final doctorNotes = (c?['doctorTextResponse'] ?? c?['doctorNotes']) as String?;
    final doctorFileUrl = c?['doctorFileUrl'] as String?;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header 
            Text('Response',
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('Review the patient form and send your response.',
                style:
                    GoogleFonts.manrope(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 24),

            // ── Patient form card (expandable)
            GestureDetector(
              onTap: () => setState(() => _formExpanded = !_formExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0B38),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: const Color(0x331D1F8C), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: type badge + form badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _typeBadge(isEmerg),
                        _miniBadge(Icons.folder_copy_rounded, 'Patient form'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(patientName,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Age $age  •  $gender',
                        style: GoogleFonts.manrope(
                            fontSize: 13, color: Colors.white54)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tap to ${_formExpanded ? "collapse" : "view form details"}',
                          style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: kAccentBright.withOpacity(0.8)),
                        ),
                        Icon(
                          _formExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ],
                    ),

                    // Expandable detail section
                    if (_formExpanded) ...[
                      const Divider(color: Colors.white12, height: 24),
                      _infoRow(Icons.description_rounded, 'Problem', problem),
                      if (patientFileUrl != null &&
                          patientFileUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(patientFileUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: kAccentBright.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: kAccentBright.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              Icon(Icons.attach_file_rounded,
                                  size: 16, color: kAccentBright),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Patient document — tap to view',
                                    style: GoogleFonts.manrope(
                                        fontSize: 12, color: Colors.white70)),
                              ),
                              const Icon(Icons.open_in_new,
                                  size: 14, color: Colors.white38),
                            ]),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Doctor's Response Section
            if (alreadyResponded) ...[
              _buildDoctorResponseSection(
                doctorNotes: doctorNotes,
                doctorFileUrl: doctorFileUrl,
              ),
              const SizedBox(height: 24),
            ],

            // ── Response form or already responded message
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0B38),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x331D1F8C), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: alreadyResponded
                  ? _alreadyRespondedWidget()
                  : _responseFormWidget(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _responseFormWidget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Give response',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(
              'Upload the prescription and write what the patient should do and avoid.',
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 18),

          // Notes input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF080826),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x331D1F8C)),
            ),
            child: TextField(
              controller: _notesCtrl,
              maxLines: 5,
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    'Type your instructions (what to do / what not to do)...',
                hintStyle:
                    GoogleFonts.manrope(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upload prescription button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: const BorderSide(color: Color(0x551D1F8C)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _pickPrescription,
            icon: Icon(Icons.attach_file_rounded, size: 16, color: kAccentBright),
            label: Text(
              _prescriptionFileName == null
                  ? 'Upload prescription'
                  : _prescriptionFileName!,
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_prescriptionFileName != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.check_circle_outline, size: 14, color: kNormal),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _prescriptionFileName!,
                  style: GoogleFonts.manrope(fontSize: 11, color: kNormal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: kAccentBright,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 6,
              ),
              onPressed: _isSubmitting ? null : _submitDoctorResponse,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text('Give response',
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      );

  Widget _alreadyRespondedWidget() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: kNormal, size: 56),
          const SizedBox(height: 12),
          Text('Response sent!',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text('You have already responded to this consultation.',
              style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      );

  Widget _buildDoctorResponseSection({
    required String? doctorNotes,
    required String? doctorFileUrl,
  }) {
    final hasNotes = doctorNotes != null && doctorNotes.isNotEmpty;
    final hasFile = doctorFileUrl != null && doctorFileUrl.isNotEmpty;
    
    if (!hasNotes && !hasFile) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kNormal.withOpacity(0.3), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: kNormal.withOpacity(0.1),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.medical_services_rounded, color: kNormal, size: 22),
            const SizedBox(width: 12),
            Text('Doctor\'s Response',
                style: GoogleFonts.poppins(
                    color: kNormal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ]),
          const SizedBox(height: 16),
          
          // Doctor notes
          if (hasNotes) ...[
            Text('Instructions',
                style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kNormal.withOpacity(0.2)),
              ),
              child: Text(
                doctorNotes,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Prescription file
          if (hasFile) ...[
            if (hasNotes) const SizedBox(height: 16),
            Text('Prescription',
                style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(doctorFileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kNormal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kNormal.withOpacity(0.4)),
                ),
                child: Row(children: [
                  Icon(Icons.description_rounded, color: kNormal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('View Prescription',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('Tap to open document',
                            style: GoogleFonts.manrope(
                                color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new, color: Colors.white54, size: 18),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniBadge(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x331D1F8C)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: kNormal),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
        ]),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.oswald(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Colors.white38)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.manrope(
                      fontSize: 13, color: Colors.white)),
            ]),
          ),
        ]),
      );
}
