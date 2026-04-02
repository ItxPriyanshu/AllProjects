import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/patient/providers/auth_provider.dart';
import 'package:frontend/patient/services/authgate.dart';
import 'package:frontend/patient/patienthome.dart';

class PatientSignupScreen extends StatelessWidget {
  const PatientSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      child: PatientHome(),
      fallback: _SignupForm(),
    );
  }
}

class _SignupForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'phoneNo': _phoneCtrl.text.trim(),
    };

    final auth = ref.read(authProvider.notifier);
    final success = await auth.signUp(data, false);

    final state = ref.read(authProvider);
    if (!success) {
      final error = state.error ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1F8C),
        title: Text('Patient Signup', style: GoogleFonts.poppins()),
      ),
      backgroundColor: const Color(0xFF0F0024),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Create an account', style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                decoration: const InputDecoration(labelText: 'Full name', filled: true, fillColor: Color(0xFF111023)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Color(0xFF111023)),
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Color(0xFF111023)),
                validator: (v) => v == null || v.length < 6 ? 'Password min 6 chars' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white)),
                decoration: const InputDecoration(labelText: 'Phone Number', filled: true, fillColor: Color(0xFF111023)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 20),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D1F8C), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('Sign up', style: GoogleFonts.manrope(textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
