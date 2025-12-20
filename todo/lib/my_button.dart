import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String buttonName;
  VoidCallback onPressed;

  MyButton({super.key, required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: BoxBorder.symmetric(),
      onPressed: onPressed,
      elevation: 1,
      color: const Color.fromARGB(255, 204, 203, 203),
      child: Text(buttonName),
    );
  }
}
