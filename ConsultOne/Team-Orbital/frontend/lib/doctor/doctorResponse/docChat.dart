import 'dart:convert';
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';

// ── Colour palette 
const Color kBg = Color(0xFF03020F);
const Color kSurface = Color(0xFF080826);
const Color kAccent = Color(0xFF1D1F8C);
const Color kAccentBright = Color(0xFF3D40CC);
const Color kCardBg = Color(0x1A1D1F8C);
const Color kCardBorder = Color(0x331D1F8C);
const Color kEmergency = Color(0xFFFF4C6A);
const Color kNormal = Color(0xFF00D4AA);
const Color kWhite = Colors.white;

// ── Responsive helper 
extension _Resp on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double sp(double base) => base * (sw / 390).clamp(0.82, 1.22);
}

class DocResponseScreen extends StatefulWidget {
  final String consultationId;
  final bool isEmergency;

  const DocResponseScreen({
    super.key,
    required this.consultationId,
    this.isEmergency = false,
  });

  @override
  State<DocResponseScreen> createState() => _DocResponseScreenState();
}

class _DocResponseScreenState extends State<DocResponseScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();

  bool _loading = true;
  bool _submitting = false;
  bool _callLoading = false;

  Map<String, dynamic>? _consultation;
  String? _decryptedPatientFileB64;

  String? _prescriptionFileName;
  List<int>? _prescriptionBytes;

  bool get _isEmergency {
    if (_consultation != null) {
      return (_consultation!['type'] as String? ?? '').toLowerCase() == 'emergency';
    }
    return widget.isEmergency;
  }

  bool get _isResponded =>
      (_consultation?['status'] as String? ?? '') == 'responded';

  @override
  void initState() {
    super.initState();
    _fetchConsultation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchConsultation() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final token = await TokenStorage.getToken();
      final res = await _api.get(
        '/doctor/showform/${widget.consultationId}',
        token: token,
      );
      if (mounted) {
        setState(() {
          final data = res as Map<String, dynamic>;
          // Server returns the consultation object directly (not nested).
          // Fall back to using data itself if no 'consultation' wrapper key.
          _consultation = (data['consultation'] as Map<String, dynamic>?) ?? data;
          // Use decryptedPatientFile if available, otherwise fall back to patientFileUrl.
          _decryptedPatientFileB64 = data['decryptedPatientFile'] as String?
              ?? _consultation?['patientFileUrl'] as String?;
          final existing = _consultation?['doctorTextResponse'] as String?;
          if (existing != null && existing.isNotEmpty && _controller.text.isEmpty) {
            _controller.text = existing;
          }
          _loading = false;
        });
      }
    } catch (e) {
      developer.log('DocResponseScreen fetch error: $e');
      if (mounted) {
        setState(() => _loading = false);
        _showSnack(
          'Failed to load consultation: ${e.toString().replaceFirst('Exception: ', '')}',
          error: true,
        );
      }
    }
  }

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

  Future<void> _submitResponse() async {
    if (_submitting) return;
    final text = _controller.text.trim();
    if (text.isEmpty && _prescriptionBytes == null) {
      _showSnack('Please enter instructions or upload a prescription.', 
          error: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        _showSnack('Not authenticated. Please log in again.', error: true);
        return;
      }

      // Build multipart request directly so we have full control over
      // the response and can log exactly what the server returns.
      final uri = Uri.parse(
          '${ApiService.baseUrl}/doctor/form/${widget.consultationId}');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['textResponse'] = text;

      if (_prescriptionBytes != null && _prescriptionBytes!.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'doctorAnswer',
          _prescriptionBytes!,
          filename: _prescriptionFileName ?? 'prescription',
        ));
      }

      developer.log(
        'DocResponseScreen: POST ${uri.path} | textResponse length=${text.length} | file=${_prescriptionFileName ?? 'none'}',
        name: 'DocSubmit',
      );

      // 60-second timeout — Render free tier can cold-start slowly.
      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw Exception('Request timed out. The server may be waking up — please try again.'),
      );
      final response = await http.Response.fromStream(streamed);

      developer.log(
        'DocResponseScreen: status=${response.statusCode} body=${response.body}',
        name: 'DocSubmit',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSnack('Response submitted successfully!');
          await _fetchConsultation();
        }
      } else {
        // Extract the most useful message from whatever the server returned.
        String serverMsg = 'Server error ${response.statusCode}';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          serverMsg = (body['error'] ?? body['message'] ?? serverMsg).toString();
        } catch (_) {
          serverMsg = '${response.statusCode}: ${response.body}';
        }
        _showSnack('Submit failed: $serverMsg', error: true);
      }
    } catch (e) {
      developer.log('DocResponseScreen submit error: $e', name: 'DocSubmit');
      _showSnack(
        e.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _handleVoiceCall() async {
    if (_callLoading) return;
    setState(() => _callLoading = true);
    try {
      final token = await TokenStorage.getToken();
      final res = await _api.get(
        '/doctor/emergency/masked/${widget.consultationId}',
        token: token,
      );
      final maskedNumber = (res as Map<String, dynamic>)['maskedNumber'] as String?;
      if (maskedNumber == null || maskedNumber.isEmpty) {
        _showSnack('Patient number unavailable.', error: true);
        return;
      }
      if (mounted) _showCallDialog(maskedNumber);
    } catch (e) {
      _showSnack(
        'Call failed: ${e.toString().replaceFirst('Exception: ', '')}',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _callLoading = false);
    }
  }

  void _showCallDialog(String maskedNumber) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C0B38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: kEmergency.withOpacity(0.3)),
        ),
        title: Text(
          'Masked Call',
          style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your call will be connected via a masked number to protect patient privacy.',
              style: GoogleFonts.manrope(color: kWhite.withOpacity(0.7), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCardBorder),
              ),
              child: Text(
                maskedNumber,
                style: GoogleFonts.poppins(
                  color: kAccentBright,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: kWhite.withOpacity(0.6))),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri(scheme: 'tel', path: maskedNumber);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            icon: const Icon(Icons.call_rounded, color: kWhite),
            label: Text('Call Now',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kEmergency,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVideoCall() async {
    try {
      final uri = Uri.parse(
          'https://meet.jit.si/consultone-${widget.consultationId}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('Could not open video call.', error: true);
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}', error: true);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? kEmergency : kNormal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: kAccentBright))
            : RefreshIndicator(
                color: kAccentBright,
                onRefresh: _fetchConsultation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      context.sp(20), context.sp(20),
                      context.sp(20), context.sp(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: context.sp(6)),
                      Text(
                        'Review the patient form and send your response.',
                        style: GoogleFonts.manrope(
                          fontSize: context.sp(12.5),
                          color: kWhite.withOpacity(0.45),
                        ),
                      ),
                      SizedBox(height: context.sp(24)),
                      _buildPatientCard(context),
                      SizedBox(height: context.sp(20)),
                      if (_decryptedPatientFileB64 != null) ...[
                        _buildPatientFileSection(context),
                        SizedBox(height: context.sp(20)),
                      ],
                      if (_isEmergency) ...[
                        _buildEmergencyCallSection(context),
                        SizedBox(height: context.sp(20)),
                      ],
                      _buildResponseCard(context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(context.sp(8)),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCardBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: context.sp(16), color: kWhite),
          ),
        ),
        SizedBox(width: context.sp(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response',
                style: GoogleFonts.poppins(
                  fontSize: context.sp(24),
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                ),
              ),
              Text(
                'PATIENT FORM',
                style: GoogleFonts.oswald(
                  fontSize: context.sp(10),
                  letterSpacing: 2.5,
                  color: kAccentBright.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        if (_isResponded)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: context.sp(10), vertical: context.sp(5)),
            decoration: BoxDecoration(
              color: kNormal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kNormal.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: context.sp(12), color: kNormal),
                SizedBox(width: context.sp(4)),
                Text(
                  'Responded',
                  style: GoogleFonts.manrope(
                      fontSize: context.sp(10.5),
                      color: kNormal,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context) {
    final c = _consultation ?? {};
    final name = c['full_name'] as String? ?? 'Patient';
    final age = c['age']?.toString() ?? '-';
    final gender = c['gender'] as String? ?? '-';
    final contactNo = c['contactNo'] as String? ?? '-';
    final problem = c['Problem'] as String? ?? c['problem'] as String? ?? '-';
    final lifestyle = c['life_style'] as String? ?? '-';
    final typeLabel = _isEmergency ? 'EMERGENCY' : 'NORMAL';
    final typeColor = _isEmergency ? kEmergency : kNormal;

    String dateStr = '-', timeStr = '-';
    try {
      final dt = DateTime.parse(c['createdAt']?.toString() ?? '').toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      final hour =
          dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      timeStr =
          '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {}

    return Container(
      padding: EdgeInsets.all(context.sp(18)),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38),
        borderRadius: BorderRadius.circular(context.sp(18)),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
              color: kAccent.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PATIENT DETAILS',
                style: GoogleFonts.oswald(
                    fontSize: context.sp(10.5),
                    letterSpacing: 1.8,
                    color: kWhite.withOpacity(0.35)),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.sp(9), vertical: context.sp(3.5)),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        _isEmergency
                            ? Icons.emergency_rounded
                            : Icons.healing_rounded,
                        size: context.sp(10.5),
                        color: typeColor),
                    SizedBox(width: context.sp(4)),
                    Text(typeLabel,
                        style: GoogleFonts.oswald(
                            fontSize: context.sp(10.5),
                            letterSpacing: 0.8,
                            color: typeColor,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(12)),
          Text(name,
              style: GoogleFonts.poppins(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w600,
                  color: kWhite)),
          SizedBox(height: context.sp(3)),
          Text('Age $age \u00b7 $gender',
              style: GoogleFonts.manrope(
                  fontSize: context.sp(12.5),
                  color: kWhite.withOpacity(0.5))),
          SizedBox(height: context.sp(14)),
          _DocInfoRow(icon: Icons.phone_rounded, label: contactNo),
          SizedBox(height: context.sp(7)),
          _DocInfoRow(icon: Icons.calendar_today_rounded, label: dateStr),
          SizedBox(height: context.sp(7)),
          _DocInfoRow(icon: Icons.access_time_rounded, label: timeStr),
          SizedBox(height: context.sp(16)),
          Divider(color: kCardBorder, thickness: 1),
          SizedBox(height: context.sp(14)),
          Text('Complaint',
              style: GoogleFonts.oswald(
                  fontSize: context.sp(10.5),
                  letterSpacing: 1.5,
                  color: kWhite.withOpacity(0.35))),
          SizedBox(height: context.sp(5)),
          Text(problem,
              style: GoogleFonts.manrope(
                  fontSize: context.sp(13), color: kWhite.withOpacity(0.87))),
          if (lifestyle != '-') ...[
            SizedBox(height: context.sp(12)),
            Text('Lifestyle',
                style: GoogleFonts.oswald(
                    fontSize: context.sp(10.5),
                    letterSpacing: 1.5,
                    color: kWhite.withOpacity(0.35))),
            SizedBox(height: context.sp(5)),
            Text(lifestyle,
                style: GoogleFonts.manrope(
                    fontSize: context.sp(13),
                    color: kWhite.withOpacity(0.87))),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientFileSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38),
        borderRadius: BorderRadius.circular(context.sp(16)),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.sp(10)),
            decoration: BoxDecoration(
              color: kAccentBright.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_rounded,
                size: context.sp(24), color: kAccentBright),
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Attachment',
                    style: GoogleFonts.poppins(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w600,
                        color: kWhite)),
                Text('File uploaded by patient',
                    style: GoogleFonts.manrope(
                        fontSize: context.sp(11),
                        color: kWhite.withOpacity(0.5))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: context.sp(8), vertical: context.sp(4)),
            decoration: BoxDecoration(
              color: kNormal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kNormal.withOpacity(0.35)),
            ),
            child: Text('Available',
                style: GoogleFonts.manrope(
                    fontSize: context.sp(10),
                    color: kNormal,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCallSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: kEmergency.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.sp(16)),
        border: Border.all(color: kEmergency.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_rounded,
                  size: context.sp(18), color: kEmergency),
              SizedBox(width: context.sp(8)),
              Expanded(
                child: Text(
                  'Emergency Case \u2013 Connect with Patient',
                  style: GoogleFonts.poppins(
                      fontSize: context.sp(12.5),
                      fontWeight: FontWeight.w600,
                      color: kEmergency),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EmergencyCallButton(
                icon: _callLoading
                    ? Icons.hourglass_empty_rounded
                    : Icons.phone_in_talk_rounded,
                label: _callLoading ? 'Connecting\u2026' : 'Voice Call',
                onPressed: _callLoading ? () {} : _handleVoiceCall,
              ),
              _EmergencyCallButton(
                icon: Icons.videocam_rounded,
                label: 'Video Call',
                onPressed: _handleVideoCall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(18)),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38),
        borderRadius: BorderRadius.circular(context.sp(18)),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
              color: kAccent.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isResponded ? 'Your Response' : 'Give Response',
            style: GoogleFonts.poppins(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
                color: kWhite),
          ),
          SizedBox(height: context.sp(6)),
          Text(
            'Upload the prescription and write what the patient should do and avoid.',
            style: GoogleFonts.manrope(
                fontSize: context.sp(12), color: kWhite.withOpacity(0.45)),
          ),
          SizedBox(height: context.sp(18)),
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(context.sp(16)),
              border: Border.all(color: kCardBorder),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              readOnly: _isResponded,
              style:
                  GoogleFonts.manrope(color: kWhite, fontSize: context.sp(13)),
              decoration: InputDecoration(
                hintText: _isResponded
                    ? 'No notes provided.'
                    : 'Type your instructions here (what to do / what not to do)\u2026',
                hintStyle:
                    GoogleFonts.manrope(color: kWhite.withOpacity(0.3)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(context.sp(14)),
              ),
            ),
          ),
          if (!_isResponded) ...[
            SizedBox(height: context.sp(16)),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: context.sp(16), vertical: context.sp(12)),
                side: BorderSide(
                    color: _prescriptionFileName != null
                        ? kNormal.withOpacity(0.5)
                        : kCardBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _pickPrescription,
              icon: Icon(
                  _prescriptionFileName != null
                      ? Icons.check_circle_rounded
                      : Icons.attach_file_rounded,
                  size: context.sp(16),
                  color: _prescriptionFileName != null
                      ? kNormal
                      : kAccentBright),
              label: Text(
                _prescriptionFileName ?? 'Upload prescription',
                style: GoogleFonts.manrope(
                    fontSize: context.sp(12),
                    color:
                        _prescriptionFileName != null ? kNormal : kWhite),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: context.sp(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: context.sp(14)),
                  backgroundColor: kAccentBright,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                ),
                onPressed: _submitting ? null : _submitResponse,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kWhite))
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _submitting ? 'Submitting\u2026' : 'Give Response',
                  style: GoogleFonts.manrope(
                      fontSize: context.sp(14), fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (_isResponded) ...[
            SizedBox(height: context.sp(16)),
            Container(
              padding: EdgeInsets.all(context.sp(12)),
              decoration: BoxDecoration(
                color: kNormal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kNormal.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: kNormal, size: context.sp(18)),
                  SizedBox(width: context.sp(10)),
                  Expanded(
                    child: Text(
                      'Response already submitted. The patient can now view your prescription.',
                      style: GoogleFonts.manrope(
                          fontSize: context.sp(12),
                          color: kNormal.withOpacity(0.9)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DocInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: context.sp(12), color: kWhite.withOpacity(0.35)),
        SizedBox(width: context.sp(5)),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: context.sp(11.5), color: kWhite.withOpacity(0.55)),
        ),
      ],
    );
  }
}

class _EmergencyCallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _EmergencyCallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.sp(20), vertical: context.sp(12)),
        decoration: BoxDecoration(
          color: kEmergency.withOpacity(0.15),
          borderRadius: BorderRadius.circular(context.sp(12)),
          border: Border.all(color: kEmergency.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.sp(26), color: kEmergency),
            SizedBox(height: context.sp(6)),
            Text(
              label,
              style: GoogleFonts.manrope(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w600,
                  color: kEmergency),
            ),
          ],
        ),
      ),
    );
  }
}
