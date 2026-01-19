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
                children: [
                  Text(
                    "Features",
                    style: GoogleFonts.firaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  //features card/containers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                      Container(
                        
                        width: 150.w,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.lightGreenAccent.withAlpha(20),width: 1),
                          borderRadius: BorderRadius.circular(16),
                          color: Color.fromARGB(80, 62, 86, 76),
                        ),
                        child: Text('data'),
                      ),
                    ],
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
