import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final List<Map<String, dynamic>> leaderboardData = [
    {"name": "Priyanshu", "gems": 15},
    {"name": "Shreyas", "gems": 12},
    {"name": "Maaz", "gems": 10},
    {"name": "Pushpam", "gems": 8},
    {"name": "Utkarsh", "gems": 7},
    {"name": "Soni", "gems": 6},
    {"name": "Rajat", "gems": 5},
    {"name": "Aman", "gems": 4},
    {"name": "You", "gems": 3}, // 👈 your entry
  ];

  @override
  Widget build(BuildContext context) {
    // Sort descending by gems
    leaderboardData.sort((a, b) => b['gems'].compareTo(a['gems']));

    // Find your rank
    int myRank = leaderboardData.indexWhere((user) => user['name'] == "You") + 1;
    int myGems = leaderboardData.firstWhere((user) => user['name'] == "You")['gems'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 247, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main leaderboard
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top 3 Leaderboard
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 2nd place
                      _buildTopUser(
                        context,
                        rank: 2,
                        name: leaderboardData[1]['name'],
                        gems: leaderboardData[1]['gems'],
                        color: Colors.grey.shade400,
                      ),
                      // 1st place
                      _buildTopUser(
                        context,
                        rank: 1,
                        name: leaderboardData[0]['name'],
                        gems: leaderboardData[0]['gems'],
                        color: Colors.amber,
                        isBig: true,
                      ),
                      // 3rd place
                      _buildTopUser(
                        context,
                        rank: 3,
                        name: leaderboardData[2]['name'],
                        gems: leaderboardData[2]['gems'],
                        color: Colors.brown.shade300,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Rest of the leaderboard (excluding "You")
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaderboardData.length - 4,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index + 3];
                    if (user['name'] == "You") return const SizedBox.shrink(); // skip "You"
                    return _buildUserTile(user['name'], user['gems'], index + 4);
                  },
                ),
                const SizedBox(height: 80), // space for floating card
              ],
            ),
          ),

          // Floating "My Rank" card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: const Text(
                  "You",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text("$myGems Gems"),
                trailing: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    "$myRank",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUser(
    BuildContext context, {
    required int rank,
    required String name,
    required int gems,
    required Color color,
    bool isBig = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: isBig ? 40 : 30,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue, size: 30),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("$gems Gems", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildUserTile(String name, int gems, int rank) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$gems Gems"),
        trailing: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            "$rank",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
