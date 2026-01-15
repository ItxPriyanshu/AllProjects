import 'package:dropnote/features/ProfileScreen/profile_screen.dart';
import 'package:dropnote/features/homescreen/home_screen.dart';
import 'package:dropnote/features/trendingScreen/trending_screen.dart';
import 'package:dropnote/providers/onscreen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const TrendingScreen(),
      const HomeScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: ,
    );
  }
}