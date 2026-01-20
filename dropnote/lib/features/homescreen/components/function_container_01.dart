// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dropnote/features/noteScreen/note_screen.dart';

class FunctionContainer01 extends StatelessWidget {
  final IconData icon;
  final IconData icon2;
  final Color color;
  final String title;
  final String subtitle;
  final int width;
  final bool wide;
  final Color tilecolor;
  final Widget? NavigateTo;
  const FunctionContainer01({
    Key? key,
    required this.icon,
    required this.icon2,
    required this.color,
    required this.title,
    required this.subtitle,
    this.width = 165,
    required this.wide,
    this.tilecolor = const Color.fromARGB(255, 43, 84, 56),
    this.NavigateTo = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!wide)
        ? Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                if (NavigateTo == null) {
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: "Oh Wait",
                      message: "The feature is in development 🛠️",
                      contentType: ContentType.failure,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NavigateTo!),
                  );
                }
              },
              splashColor: Colors.lightGreenAccent.withAlpha(20),
              // highlightColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: width.w,
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withAlpha(50),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  // color: Color.fromARGB(80, 62, 86, 76),
                  gradient: LinearGradient(
                    colors: [Color(0xFF111212), tilecolor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          Icon(icon2, size: 25),
                        ],
                      ),
                      SizedBox(height: 40),
                      //title
                      Text(
                        title,
                        style: GoogleFonts.firaSansCondensed(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 5),
                      //subtitle
                      Text(
                        subtitle,
                        style: GoogleFonts.firaSansCondensed(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Material(
            type: MaterialType.transparency,
            child: InkWell(
              splashColor: Colors.lightGreenAccent.withAlpha(20),
              // highlightColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (NavigateTo == null) {
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: "Oh Wait",
                      message: "The feature is in development 🛠️",
                      contentType: ContentType.failure,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NavigateTo!),
                  );
                }
              },
              child: Ink(
                // width: width.w,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withAlpha(30),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  // color: Color.fromARGB(80, 62, 86, 76),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF111212), tilecolor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      SizedBox(width: 30.w),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //title
                                Text(
                                  title,
                                  style: GoogleFonts.firaSansCondensed(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 2),
                                //subtitle
                                Text(
                                  subtitle,
                                  style: GoogleFonts.firaSansCondensed(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Icon(icon2, size: 25),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
