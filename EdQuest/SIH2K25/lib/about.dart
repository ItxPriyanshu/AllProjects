import 'package:flutter/material.dart';

class AboutUsSimplePage extends StatelessWidget {
  const AboutUsSimplePage({super.key});

  // Helper for section titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
        title: const Text("About Our App",style: TextStyle(color: Colors.white),),
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
                    Image.asset('assets/images/logo_edquest.png'),
                    const SizedBox(height: 16),
                    const Text(
                      "EdQuest", // our App Name
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Empowering Rural Minds",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Core Features ---
              _buildSectionHeader("Core Features"),
              ListTile(
                leading: Icon(Icons.offline_bolt, color: Colors.blue),
                title: const Text("Offline Content", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Access interactive games and quizzes with limited or no internet connectivity."),
              ),
              ListTile(
                leading: Icon(Icons.gamepad, color: Colors.blue),
                title: const Text("Gamified Learning", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Daily challenges and learning streaks make education fun and consistent."),
              ),
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue),
                title: const Text("Multilingual Support", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Content available in both English and Hindi on any low-cost device."),
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.blue),
                title: const Text("AI Guru Chatbot", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("An interactive chatbot to help students with their academic doubts."),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.blue),
                title: const Text("Teacher Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Analytics for teachers to easily track and monitor student progress."),
              ),
              
              // --- Our Plan ---
              _buildSectionHeader("Our Plan"),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue, child: Text("1", style: TextStyle(color: Colors.white))),
                title: Text("Pilot Program", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Test the app in schools to get feedback and make improvements."),
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue, child: Text("2", style: TextStyle(color: Colors.white))),
                title: Text("Phased Rollout", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Gradually expand access to more schools to ensure a smooth launch."),
              ),

              // --- Expected Outcome ---
              _buildSectionHeader("Expected Outcome"),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        "15%+",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Minimum expected increase in student engagement.",
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}