// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FunctionContainer02 extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget widget;
  const FunctionContainer02({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: (){},
        splashColor: Colors.lightGreenAccent.withAlpha(20),
        // highlightColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          // width: width.w,
          height: 90,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.lightGreenAccent.withAlpha(20),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
            // color: Color.fromARGB(80, 62, 86, 76),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 43, 84, 56), Color(0xFF111212)],
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
                SizedBox(width: 100.w),
                widget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
