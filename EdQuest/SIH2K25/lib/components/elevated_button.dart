import 'package:flutter/material.dart';
import 'package:sih_2k25/computer_page.dart';
import 'package:sih_2k25/science_page.dart';

class MyElevatedButtons extends StatelessWidget {
  String text;
  MyElevatedButtons({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: Colors.black,
        foregroundColor: Colors.black,
        side: BorderSide(color: const Color.fromARGB(255, 102, 102, 102)),
      ),
      onPressed: () {
        if (text == 'Science') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SciencePage()),
          );
        } else if (text == 'Mathematics') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SciencePage()),
          );
        } else if (text == 'Computer Science') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComputerPage()),
          );
        }
      },
      child: Text(text),
    );
  }
}
