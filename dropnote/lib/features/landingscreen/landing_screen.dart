import 'package:dropnote/features/ProfileScreen/profile_screen.dart';
import 'package:dropnote/features/homescreen/home_screen.dart';
import 'package:dropnote/features/landingscreen/components/slidder_drawer.dart';
import 'package:dropnote/features/landingscreen/components/bottom_nav_bar.dart';
import 'package:dropnote/features/TODOScreen/todo_screen.dart';
import 'package:dropnote/providers/onscreen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    GlobalKey<SliderDrawerState> _sliderDrawerKey =
        GlobalKey<SliderDrawerState>();

    final pages = [
      const TodoScreen(),
      const HomeScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      //  appBar: AppBar(backgroundColor: const Color.fromARGB(255, 24, 24, 24),),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        title1: 'ToDo',
        icon1: Icons.checklist,
        title2: 'Home',
        icon2: Icons.home,
        title3: 'Profile',
        icon3: Icons.person,
      ),
    );
  }
}
