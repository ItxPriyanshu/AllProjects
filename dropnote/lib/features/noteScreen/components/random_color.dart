import 'dart:math';

import 'package:flutter/material.dart';
final List<Color> colorsList=[
  Colors.redAccent,
  Colors.lightGreenAccent,
  Colors.yellowAccent,
  Colors.pinkAccent,
  Colors.blueAccent,
  Colors.lightBlueAccent,
  Colors.purpleAccent,
];

Color getRandomColor(){
  final random = Random();
  return colorsList[random.nextInt(colorsList.length)];
}