import 'dart:ui';

import 'package:flutter/material.dart';

class ScheduleCell {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  ScheduleCell({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

List<ScheduleCell?> grid = List.filled(70, null);