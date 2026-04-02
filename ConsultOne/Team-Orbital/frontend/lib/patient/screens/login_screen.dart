import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/start_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/patient/providers/auth_provider.dart';
import 'package:frontend/doctor/doctorhome/doctorhome.dart';
import 'package:frontend/patient/patienthome.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isDoctor = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    await notifier.login(_emailCtrl.text.trim(), _passwordCtrl.text, _isDoctor);

    final state = ref.read(authProvider);
    if (state.isAuthenticated) {
      if (state.role == 'doctor') {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DoctorHome()));
      } else {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Scaffold(body: PatientHome())));
      }
    } else {
      final message = state.error ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F0024),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: const Color(0xFF111023),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Sign in', style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        isSelected: [_isDoctor, !_isDoctor],
                        onPressed: (i) => setState(() => _isDoctor = i == 0),
                        borderRadius: BorderRadius.circular(8),
                        fillColor: const Color(0xFF1D1F8C),
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Doctor', style: GoogleFonts.manrope(color: Colors.white))),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Patient', style: GoogleFonts.manrope(color: Colors.white))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                        decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Color(0xFF0C0B16)),
                        validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                        decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Color(0xFF0C0B16)),
                        validator: (v) => v == null || v.length < 6 ? 'Password min 6 chars' : null,
                      ),
                      const SizedBox(height: 20),
                      state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D1F8C), padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: Text('Sign in', style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StartPage())),
                        child: Text('Don\'t have an account? Sign up', style: GoogleFonts.manrope(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
