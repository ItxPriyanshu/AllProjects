import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),

      //**top part**//
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10,bottom: 10,right: 10,top: 8),
          child: Column(children: [
            Row(
              children: [
                
              ],
            )
          ],),
        ),
      ),
    );
  }
}