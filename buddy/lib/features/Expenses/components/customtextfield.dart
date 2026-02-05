// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class expenseTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const expenseTextField({
    Key? key,
    required this.title,
    required this.controller,
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      keyboardType:keyboardType,
      cursorColor: Colors.white,
       controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(60),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(

            color: Color.fromARGB(255, 255, 255, 255),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255),width: 2),
        
        ),
        label: Text(
          title,
          style: GoogleFonts.roboto(fontSize: 12, color: const Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
