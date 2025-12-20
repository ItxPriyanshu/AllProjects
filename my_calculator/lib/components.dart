import 'package:flutter/material.dart';


//button
class Button extends StatefulWidget {
  final String title;
  final Color color;
  final VoidCallback onpress;
  const Button({required this.title,
  this.color=Colors.grey,
  required this.onpress,
  super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: widget.onpress,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:widget.color,
          ),
          child: Center(
            child: Text(widget.title,style: TextStyle(fontSize: 20, color:Colors.white),),
          ),
        ),
      ),
    ));
  }
}