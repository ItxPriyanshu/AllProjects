import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih_2k25/science_chapters/unity_game_page.dart';


class UnitySplashPage extends StatefulWidget {
  const UnitySplashPage({super.key});

  @override
  State<UnitySplashPage> createState() => _UnitySplashPageState();
}

class _UnitySplashPageState extends State<UnitySplashPage> {
  @override
  void initState() {
    super.initState();

    // Delay for 3 seconds before navigating to UnityGamePage
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UnityGamePage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/lottie/Rotating_gem_gamelogolottie.json",
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading Game...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
