import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Helper for section titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Help & Support",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 26, 117, 245),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/lottie/help_animation.json', // A suitable Lottie file
                      height: 160,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "How can we help you?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Frequently Asked Questions Section ---
              _buildSectionHeader("Frequently Asked Questions"),
              
              // Using ExpansionTile for a clean, interactive FAQ list
              ExpansionTile(
                leading: const Icon(Icons.wifi_off, color: Colors.blue),
                title: const Text("How does the offline mode work?", style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Our app is designed for low connectivity. You can download chapters and quizzes when you have internet, and then access them anytime, anywhere, completely offline. Your progress will be saved and synced later.",
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.blue),
                title: const Text("How do I track my learning streak?", style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Your learning streak increases every day you complete at least one lesson or quiz. You can view your current streak on the home page. Keep it going to earn rewards!",
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                leading: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                title: const Text("What is the AIगुरु?", style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "AIगुरु is your personal AI-powered assistant. You can ask it academic questions from your subjects, and it will provide explanations and help you solve your doubts instantly.",
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

              // --- Contact Us Section ---
              _buildSectionHeader("Still need help?"),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Icon(Icons.email_outlined, size: 32, color: Colors.black87),
                  title: const Text("Email Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text("Get in touch with our support team for any queries."),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement email launcher functionality
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Icon(Icons.forum_outlined, size: 32, color: Colors.black87),
                  title: const Text("Community Forum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text("Ask questions and get help from other users."),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                   
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}