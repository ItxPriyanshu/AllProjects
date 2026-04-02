import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorHelpSupport extends StatelessWidget {
  const DoctorHelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1F8C),
        title: Text('Help & Support', style: GoogleFonts.poppins()),
      ),
      backgroundColor: const Color(0xFF0F0024),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _FaqCard(
              question: 'How do I join a video consultation?',
              answer: 'When a patient requests a video call you will receive a push notification with a Meet link. Tap Join to open Google Meet.',
            ),
            _FaqCard(
              question: 'How do I update my availability?',
              answer: 'Go to Profile → Edit and change your availability time slot, then save.',
            ),
            _FaqCard(
              question: 'What if I do not receive notifications?',
              answer: 'Ensure notifications are enabled for the app in Android/iOS settings and you are logged in on a single device.',
            ),
            _FaqCard(
              question: 'Can I offer free consultations?',
              answer: 'Yes — set your consultation fees to 0 in the signup/profile page. Note: emergency routing may be disabled for free consultations.',
            ),
            const SizedBox(height: 18),
            Text('Still need help?', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0F32),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white70),
                      const SizedBox(width: 12),
                      Expanded(child: Text('utkarsh.240101060@iiitbh.ac.in', style: GoogleFonts.manrope(color: Colors.white70))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70),
                      const SizedBox(width: 12),
                      Text('+91-XXXX-XXX-123', style: GoogleFonts.manrope(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('We typically respond within 24 hours.', style: GoogleFonts.manrope(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Center(
              child: Text('Thank you for contributing to patient care.', style: GoogleFonts.manrope(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF131026),
        backgroundColor: const Color(0xFF131026),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text(question, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(answer, style: GoogleFonts.manrope(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
