import 'package:dropnote/features/homescreen/components/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
     
      body:Column(
        children: [
          MyCarouselSlider(),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Container(
              color:  Colors.grey.withAlpha(100),
              height: 1,
            ),
          ),

        ],
      ),
    );
  }
}