import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SliderDrawerContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color mcolor;
  const SliderDrawerContainer({
    super.key,
    required this.title,
    required this.icon,
    this.mcolor = Colors.lightGreenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          //future navigation
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.lightGreenAccent,
          elevation: 5,
          shadowColor: const Color.fromARGB(255, 100, 100, 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero, //removes default padding
        ),
        child: ListTile(
          leading: Icon(icon, color: mcolor),
          title: Text(
            title,
            style: GoogleFonts.firaSansCondensed(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
