import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

@override
  void initState() {
    super.initState();
    Timer((Duration(seconds: 1)), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:Center(child: Image.asset('assets/ToDo_icon.png'),
    ));

  }
}

// Container(
        
//         height: 150,
//         width: 90,
//         child: Text('ToDo',style: TextStyle(fontSize: 50,fontFamily: 'JuliusSansOne',color: Colors.white),))),

//