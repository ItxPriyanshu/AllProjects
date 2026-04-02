import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih_2k25/components/drawer.dart';
import 'package:sih_2k25/components/notification_tile.dart';
import 'package:sih_2k25/science_page.dart';
import 'package:sih_2k25/aiguru.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:badges/badges.dart' as badges;
import 'package:sih_2k25/streakNstatistics.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String userName;

  const HomePage({super.key, required this.token, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String displayName;

  @override
  void initState() {
    super.initState();
    displayName = widget.userName;
  }

  // Fixed navigation functions
  void _openMath() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SciencePage()));
  void _openScience() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SciencePage()));
  void _openComputer() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SciencePage()));

  // Subject card widget
  Widget _subjectCard(String title, String lottiePath, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.only(top: 5,right: 5,left: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  const Color.fromARGB(255, 90, 157, 251),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Lottie.asset(lottiePath, fit: BoxFit.contain), // 🔹 Lottie logic unchanged
                ),
              ),
              // const SizedBox(height: 5),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(title,style: TextStyle(fontWeight: FontWeight.w500),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 26, 117, 245),
        title: Text(
          "Hey $displayName 👋",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Streaknstatistics()),
              );
            },
            child: badges.Badge(
              badgeContent: const Text('7'),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color(0xFFFF887F),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            NotificationTile(
                              title: 'New Chapter added',
                              subtitle: 'Lines and angles chapter is available',
                            ),

                            NotificationTile(
                              title: 'New feature',
                              subtitle:
                                  'New gems feature is added from which you can buy new paid courses for free',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: badges.Badge(
              badgeContent: const Text(""),
              badgeStyle: const badges.BadgeStyle(badgeColor: Color(0xFFFF887F)),
              position: badges.BadgePosition.topEnd(top: -2, end: -2),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      drawer: const Drawer(backgroundColor: Colors.white,child: MyDrawer()),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // 🔹 Gradient background like original
              Container(
                width: double.infinity,
                height: 341,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color.fromARGB(255, 255, 255, 255),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(child: Text(tr('ready_to'), style: const TextStyle(fontSize: 55, fontFamily: 'Barlow', fontWeight: FontWeight.w700, color: Color(0xFF333333)))),
                        FittedBox(child: Text(tr('level_up'), style: const TextStyle(fontSize: 55, fontFamily: 'Barlow', fontWeight: FontWeight.w700, color: Color(0xFF333333)))),
                        FittedBox(child: Text(tr('today'), style: const TextStyle(fontSize: 55, fontFamily: 'Barlow', fontWeight: FontWeight.w700, color: Color(0xFF333333)))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      cursorColor: Colors.black,
                      cursorRadius: const Radius.circular(50),
                      decoration: InputDecoration(
                        
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color.fromARGB(255, 152, 199, 246))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color.fromARGB(255, 103, 186, 255), width: 2)),
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: tr('search_hint'),
                      ),
                    ),
                  ),
                  // 🔹 Three fixed subject cards
                  _subjectCard(tr('science',), "assets/lottie/science_lottie.json", _openScience),
                  SizedBox(height: 10,),
                  _subjectCard(tr('math'), "assets/lottie/math_chapterslottie.json", _openMath),
                  SizedBox(height: 10,),

                  _subjectCard(tr('computer_science'), "assets/lottie/computer_lottie.json", _openComputer),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  const Color.fromARGB(255, 201, 241, 255),
        child: Lottie.asset('assets/lottie/chatbot_header.json'),//const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              insetPadding: const EdgeInsets.only(bottom: 20, left: 60),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 1.5,
                height: MediaQuery.of(context).size.height * 0.8,
                child: const AIGuruChatbot(),
              ),
            ),
          );
        },
      ),
    );
  }
}
