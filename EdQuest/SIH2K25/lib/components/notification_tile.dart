import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  String title;
  String subtitle;
  NotificationTile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(""),
      direction: DismissDirection.endToStart,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
        
          width: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.white),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: Text("12:45 pm "),
          ),
        ),
      ),
    );
  }
}
