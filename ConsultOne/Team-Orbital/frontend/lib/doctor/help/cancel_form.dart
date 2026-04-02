import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:google_fonts/google_fonts.dart';

class Cancelform extends ConsumerStatefulWidget {
  const Cancelform({super.key});

  @override
  ConsumerState<Cancelform> createState() => _CancelformState();
}

class _CancelformState extends ConsumerState<Cancelform> {
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color darkColor = Color(0xFF080826);
  static const Color bgColor = Color(0xFF0F0024);
  static const Color surfaceColor = Color(0xFF1A0F32);
  static const Color inputColor = Color(0xFF0E0B24);

  final registrationID = TextEditingController();
  final name = TextEditingController();
  final problem = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    registrationID.dispose();
    name.dispose();
    problem.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (registrationID.text.isEmpty ||
        name.text.isEmpty ||
        problem.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields',
              style: GoogleFonts.manrope(color: Colors.white)),
          backgroundColor: const Color(0xFF1D1F8C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication token not found. Please login again.',
                  style: GoogleFonts.manrope(color: Colors.white)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }

      final apiService = ApiService();
      final response = await apiService.post(
        '/patient/problem',
        {
          'registrationID': registrationID.text.trim(),
          'name': name.text.trim(),
          'problem': problem.text.trim(),
        },
        token: token,
      );

      if (mounted) {
        if (response['issue'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cancellation request submitted successfully!',
                  style: GoogleFonts.manrope(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          registrationID.clear();
          name.clear();
          problem.clear();
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['error'] ?? 'Unknown error'}',
                  style: GoogleFonts.manrope(color: Colors.white)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',
                style: GoogleFonts.manrope(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: Icon(prefixIcon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Cancel Consultation',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.orange.withOpacity(0.4), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Submit your cancellation request and our team will process it within 24 hours.',
                      style: GoogleFonts.manrope(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _buildTextField(
              controller: registrationID,
              label: 'Consultation Registration ID',
              hint: 'Enter registration ID',
              prefixIcon: Icons.confirmation_number_outlined,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: name,
              label: 'Your Name',
              hint: 'Enter your name',
              prefixIcon: Icons.perm_identity,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: problem,
              label: 'Reason for Cancellation',
              hint: 'Describe your reason...',
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Submit Cancellation Request',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}