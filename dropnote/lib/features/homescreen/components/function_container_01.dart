import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FunctionContainer01 extends StatelessWidget {
  const FunctionContainer01({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      height: 170,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.lightGreenAccent.withAlpha(20),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Color.fromARGB(80, 62, 86, 76),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon(Icons)
            ],
          )
        ],
      ),
    );
  }
}
