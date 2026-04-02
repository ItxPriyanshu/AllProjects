import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/doctor/auth/doctor_signUp_model.dart';
import 'package:frontend/doctor/auth/doctor_signUp_provider.dart';
import 'package:frontend/doctor/doctorHome/doctorhome.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorSignupScreen extends ConsumerStatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  ConsumerState<DoctorSignupScreen> createState() =>
      _DoctorSignupScreenState();
}

class _DoctorSignupScreenState
    extends ConsumerState<DoctorSignupScreen> {

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final specialityCtrl = TextEditingController();
  final feesCtrl = TextEditingController();
  final expctrl = TextEditingController();
  bool _isSocialHelp = false;
  bool _acceptedTnC = false;

  final List<String> _specialities = [
    'Cardiologist',
    'Dermatologist',
    'General Physician',
    'Neurologist',
    'Orthopedist',
  ];
  String? _selectedSpeciality;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF4C6A)),
            const SizedBox(width: 10),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.manrope(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.manrope(
                color: const Color(0xFF3D40CC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      _showErrorDialog('Please enter your full name');
      return false;
    }
    if (expctrl.text.trim().isEmpty) {
      _showErrorDialog('Please enter your eperience');
      return false;
    }
    if (emailCtrl.text.trim().isEmpty || !emailCtrl.text.contains('@')) {
      _showErrorDialog('Please enter a valid email address');
      return false;
    }
    if (passCtrl.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return false;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      _showErrorDialog('Please enter your phone number');
      return false;
    }
    if (licenseCtrl.text.trim().isEmpty) {
      _showErrorDialog('Please enter your license number');
      return false;
    }
    final selSpeciality = _selectedSpeciality ?? specialityCtrl.text.trim();
    if (selSpeciality.isEmpty) {
      _showErrorDialog('Please select your speciality');
      return false;
    }
    if (feesCtrl.text.trim().isEmpty) {
      _showErrorDialog('Please enter consultation fees');
      return false;
    }
    try {
      double.parse(feesCtrl.text.trim());
    } catch (e) {
      _showErrorDialog('Consultation fees must be a valid number');
      return false;
    }
    if (startTime == null || endTime == null) {
      _showErrorDialog('Please select your available time slots');
      return false;
    }
    return true;
  }

  Future<void> _handleSignup() async {
    if (!_validateForm()) return;

    final availTime =
        '${startTime!.format(context)} - ${endTime!.format(context)}';
    final fees = double.parse(feesCtrl.text.trim());

    final model = DoctorSignupModel(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      licenceId: licenseCtrl.text.trim(),
      speciality: (_selectedSpeciality ?? specialityCtrl.text.trim()),
      fees: fees,
      availTime: availTime, experience: expctrl.text.trim(),
    );

    final result = await ref
        .read(doctorAuthProvider.notifier)
        .signupDoctor(model);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHome()),
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Signup failed');
      }
    }
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(doctorAuthProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D1F8C), Color(0xFF0F0024)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create doctor account",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Let patients find and book you easily",
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF120428).withOpacity(0.96),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account details",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      buildField(
                        nameCtrl,
                        "Full Name",
                        icon: Icons.person_outline,
                      ),
                      buildField(
                        emailCtrl,
                        "Email",
                        icon: Icons.email_outlined,
                      ),
                      buildField(
                        passCtrl,
                        "Password",
                        isPassword: true,
                        icon: Icons.lock_outline,
                      ),
                      buildField(
                        phoneCtrl,
                        "Phone",
                        icon: Icons.phone_outlined,
                        maxlength: 10,
                      ),
                      buildField(
                        licenseCtrl,
                        "License Number",
                        icon: Icons.badge_outlined,
                      ),
                       buildField(
                        expctrl,
                        "Experience",
                        icon: Icons.numbers,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSpeciality,
                          items: _specialities
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSpeciality = v),
                          dropdownColor: const Color(0xFF1A0F32),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.medical_information_outlined,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            hintText: 'Speciality',
                            hintStyle: GoogleFonts.manrope(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1A0F32),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF3D40CC),
                                width: 1.2,
                              ),
                            ),
                          ),
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      buildField(
                        feesCtrl,
                        "Consultation Fees",
                        icon: Icons.currency_rupee_outlined,
                        enabled: !_isSocialHelp,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isSocialHelp,
                              onChanged: (v) {
                                setState(() {
                                  _isSocialHelp = v ?? false;
                                  if (_isSocialHelp) {
                                    feesCtrl.text = '0';
                                  }
                                });
                                if (_isSocialHelp) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Social Help'),
                                      content: const Text(
                                          'Thank you for contributing to community health. Setting fees to 0 marks this consultation as social help.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _isSocialHelp = !_isSocialHelp;
                                  if (_isSocialHelp) feesCtrl.text = '0';
                                }),
                                child: const Text(
                                  'Offer free consultation as social help (set fees to 0)',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Available time",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      Colors.white.withOpacity(0.25),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => pickTime(true),
                              icon: const Icon(Icons.schedule_outlined,
                                  size: 18),
                              label: Text(
                                startTime == null
                                    ? "Start time"
                                    : startTime!.format(context),
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      Colors.white.withOpacity(0.25),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => pickTime(false),
                              icon: const Icon(Icons.schedule,
                                  size: 18),
                              label: Text(
                                endTime == null
                                    ? "End time"
                                    : endTime!.format(context),
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _acceptedTnC,
                              onChanged: (v) => setState(() => _acceptedTnC = v ?? false),
                            ),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'I agree to the ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Terms & Conditions'),
                                          content: SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: const [
                                                  Text(
                                                    'Please read these Terms & Conditions carefully. By using ConsultOne you agree to the following:',
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text('1. Professional Conduct: Provide accurate and up-to-date professional information and valid medical credentials. Offer care consistent with applicable medical standards and laws.'),
                                                  SizedBox(height: 6),
                                                  Text('2. Response Times: For routine consultations respond within 6 hours; for emergencies respond as quickly as possible and within platform guidelines (typically 30 minutes where applicable). Failure to meet response expectations may result in refunds or account actions.'),
                                                  SizedBox(height: 6),
                                                  Text('3. Confidentiality & Data Protection: Maintain strict patient confidentiality. Do not share patient information outside the platform. ConsultOne uses encryption and security measures, but you remain responsible for protecting patient data in accordance with applicable law.'),
                                                  SizedBox(height: 6),
                                                  Text('4. Appropriate Use: Do not misuse the platform, engage in abusive or fraudulent behavior, or provide advice outside your scope of practice. Violations may lead to warnings, suspension, or termination.'),
                                                  SizedBox(height: 6),
                                                  Text('5. Consequences: Breach of these terms may result in disciplinary action, including account suspension, termination, or legal action where appropriate.'),
                                                  SizedBox(height: 12),
                                                  Text('Note: This dialog contains a summary of key points. Refer to the full legal agreement or admin-provided terms for complete details before offering services on the platform.'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF3D40CC),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF3D40CC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          onPressed: (isLoading || !_acceptedTnC) ? null : _handleSignup,
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Create account",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to login screen when available
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Login screen will be available soon',
                                style: GoogleFonts.manrope(),
                              ),
                              backgroundColor: const Color(0xFF3D40CC),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log in',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: const Color(0xFF3D40CC),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();
    licenseCtrl.dispose();
    specialityCtrl.dispose();
    feesCtrl.dispose();
    super.dispose();
  }

  Widget buildField(
    
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    IconData? icon,
    bool enabled = true,
    maxlength = 30,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        maxLength: maxlength,
        
        enabled: enabled,
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          counterText: "",
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: Colors.white.withOpacity(0.7),
                ),
          hintText: hint,
          hintStyle: GoogleFonts.manrope(
            color: Colors.white.withOpacity(0.45),
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFF1A0F32),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF3D40CC),
              width: 1.2,
            ),
          ),
        ),
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}
