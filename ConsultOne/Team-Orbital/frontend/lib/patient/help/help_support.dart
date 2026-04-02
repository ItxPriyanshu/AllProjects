import 'package:flutter/material.dart';
import 'package:frontend/doctor/help/cancel_form.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientHelpSupport extends StatelessWidget {
  const PatientHelpSupport({super.key});

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
              answer: 'When your doctor initiates a video call you will receive a push notification with a Meet link. Tap Join to open Google Meet.',
            ),
            _FaqCard(
              question: 'How do I book an appointment?',
              answer: 'From the doctor profile choose a slot and confirm the booking. You will receive confirmation via the app.',
            ),
            _FaqCard(
              question: 'What if I do not receive notifications?',
              answer: 'Ensure notifications are enabled for the app in Android/iOS settings and you are logged in on a single device.',
            ),
            _FaqCard(
              question: 'How are consultations charged?',
              answer: 'Fees are shown on the doctor profile. If a doctor marks social help their fee may be 0.',
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
            const SizedBox(height: 18),
            // Patient feedback form (UI only) - backend submission TODO
            _FeedbackForm(),
            const SizedBox(height: 18),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>Cancelform()));
                },
                 child: Text('Cancel your consultation')),
            ),
               SizedBox(height: 10,),
            Center(
              child: Text('Thank you for using ConsultOne.', style: GoogleFonts.manrope(color: Colors.white54)),
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

class _FeedbackForm extends StatefulWidget {
  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  int _rating = 5;
  final TextEditingController _commentsCtrl = TextEditingController();

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121029),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Feedback', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('How was your experience?', style: GoogleFonts.manrope(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = idx),
                icon: Icon(
                  idx <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentsCtrl,
            maxLines: 4,
            style: GoogleFonts.manrope(color: Colors.white70),
            decoration: InputDecoration(
              hintText: 'Optional comments',
              hintStyle: GoogleFonts.manrope(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0E0B24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: implement backend submission for patient feedback
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback UI only — submission TODO')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D1F8C)),
                  child: const Text('Submit Feedback'),
                ),
              ),

              
            ],
          ),
          
        ],
      ),
      
    );
    
  }
}

