import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/screens/patient_consultation_chat_screen.dart';

/// Popup dialog that displays a submitted consultation form.
/// Accessible to both doctors and patients.
class ConsultationFormPopup extends StatefulWidget {
  final String consultationId;
  final bool isDoctor;
  final String doctorName;
  final String doctorSpeciality;
  final bool isEmergency;

  const ConsultationFormPopup({
    super.key,
    required this.consultationId,
    this.isDoctor = false,
    this.doctorName = 'Doctor',
    this.doctorSpeciality = 'General',
    this.isEmergency = false,
  });

  @override
  State<ConsultationFormPopup> createState() => _ConsultationFormPopupState();
}

class _ConsultationFormPopupState extends State<ConsultationFormPopup> {
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color surface = Color(0xFF1A0F32);

  final ApiService _api = ApiService();
  bool _loading = true;
  Map<String, dynamic>? _consultation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConsultationForm();
  }

  Future<void> _fetchConsultationForm() async {
    try {
      final token = await TokenStorage.getToken();
      final endpoint = widget.isDoctor
          ? '/doctor/showform/${widget.consultationId}'
          : '/patient/showform/${widget.consultationId}';
      
      final res = await _api.get(endpoint, token: token);
      if (mounted) {
        setState(() {
          if (res is Map<String, dynamic>) {
            _consultation = res['full'] as Map<String, dynamic>? ?? res;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: _loading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildFormContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading form...',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load form',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetchConsultationForm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    if (_consultation == null) {
      return _buildErrorState();
    }

    final patientName = _consultation?['full_name'] as String? ?? 'Patient';
    final problem = _consultation?['Problem'] as String? ?? 'N/A';
    final lifeStyle = _consultation?['life_style'] as String? ?? 'N/A';
    final age = _consultation?['age'] as String? ?? 'N/A';
    final gender = _consultation?['gender'] as String? ?? 'N/A';
    final contactNo = _consultation?['contactNo'] as String? ?? 'N/A';
    final patientFileUrl = _consultation?['patientFileUrl'] as String?;
    final createdAt = _consultation?['createdAt'] as String? ?? '';

    String formatDate(String dateStr) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return dateStr;
      }
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultation Form',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(createdAt),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Form content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField('Patient Name', patientName),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('Age', age),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField('Gender', gender),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormField('Contact Number', contactNo),
                const SizedBox(height: 16),
                _buildFormField('Chief Complaint', problem),
                const SizedBox(height: 16),
                _buildFormField('Medical History / Lifestyle', lifeStyle),
                const SizedBox(height: 16),
                // Display uploaded file/image if available
                if (patientFileUrl != null && patientFileUrl.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uploaded Document/Image',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            patientFileUrl,
                            fit: BoxFit.cover,
                            height: 250,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                color: Colors.white.withOpacity(0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.file_present,
                                      size: 40,
                                      color: Colors.white38,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to open document',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(patientFileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          'Tap image to open in full size',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Footer with action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PatientConsultationChatScreen(
                          consultationId: widget.consultationId,
                          doctorName: widget.doctorName,
                          doctorSpeciality: widget.doctorSpeciality,
                          isEmergency: widget.isEmergency,
                          isDoctor: widget.isDoctor,
                        ),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View Full Details',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show the consultation form popup
Future<void> showConsultationFormPopup(
  BuildContext context, {
  required String consultationId,
  required bool isDoctor,
  String doctorName = 'Doctor',
  String doctorSpeciality = 'General',
  bool isEmergency = false,
}) {
  return showDialog(
    context: context,
    builder: (context) => ConsultationFormPopup(
      consultationId: consultationId,
      isDoctor: isDoctor,
      doctorName: doctorName,
      doctorSpeciality: doctorSpeciality,
      isEmergency: isEmergency,
    ),
  );
}
