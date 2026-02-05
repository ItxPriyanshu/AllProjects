// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String headerText;
  final String descriptionText;
  final Color color;

  const NoteCard({
    Key? key,
    required this.headerText,
    required this.descriptionText,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(left: 15),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          top: BorderSide(color: color, width: 1.5),
          bottom: BorderSide(color: color, width: 1.5),
          left: BorderSide(color: color, width: 1.5),
          right: BorderSide(color: color, width: 1.5),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 25),
              child: Text(
                descriptionText,
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
