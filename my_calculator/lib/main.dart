import 'package:flutter/material.dart';
import 'package:my_calculator/home_screen.dart';

void main() {
  runApp(const MyCalculator());
}

class MyCalculator extends StatelessWidget {
  const MyCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
