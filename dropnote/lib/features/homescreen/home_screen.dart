import 'package:dropnote/features/homeScreen/components/function_container_01.dart';
import 'package:dropnote/features/homeScreen/components/function_container_02.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String greet() {
    DateTime now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) {
      return "Good Morning";
    } else if (now.hour >= 12 && now.hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final hour = now.hour;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),

      //**top part**//
      body: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          bottom: 10,
          right: 10,
          top: 55,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,

                      child: Image.asset(
                        'assets/images/default_profile_pic.png',
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welome, User',
                          style: GoogleFonts.firaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          greet(),
                          style: GoogleFonts.firaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      "Features",
                      style: GoogleFonts.firaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: 10),
                  //features card/containers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FunctionContainer01(
                        icon: Icons.checklist,
                        icon2: Icons.check_circle_outline,
                        title: "ToDo",
                        subtitle: "Schedule your work",
                        color: Colors.blue,
                        wide: false,
                      ),
                      FunctionContainer01(
                        icon: Icons.sticky_note_2,
                        icon2: Icons.edit_note,
                        color: Colors.pink,
                        title: "Notes",
                        subtitle: "Write your notes",
                        wide: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  FunctionContainer01(
                    icon: Icons.alarm,
                    icon2: Icons.alarm_add,
                    color: Colors.orange,
                    title: "Alarm",
                    subtitle: "Set your alarm",
                    wide: true,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      "Others",
                      style: GoogleFonts.firaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: 10),
                  FunctionContainer02(
                    icon: Icons.cloud,
                    color: Colors.lightBlue,
                    title: "Weather",
                    subtitle: "Current Weather",
                    widget: Text(
                      '23°',
                      style: GoogleFonts.firaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  FunctionContainer02(
                    icon: Icons.wallet_outlined,
                    color: Colors.lightBlueAccent,
                    title: "Expenses",
                    subtitle: "Track your expenses",
                    widget: Text(
                      '₹ 753',
                      style: GoogleFonts.firaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
