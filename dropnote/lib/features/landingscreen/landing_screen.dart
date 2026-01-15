import 'package:dropnote/features/ProfileScreen/profile_screen.dart';
import 'package:dropnote/features/homescreen/components/slidder_drawer.dart';
import 'package:dropnote/features/homescreen/home_screen.dart';
import 'package:dropnote/features/landingscreen/components/bottom_nav_bar.dart';
import 'package:dropnote/features/trendingScreen/trending_screen.dart';
import 'package:dropnote/providers/onscreen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    GlobalKey<SliderDrawerState> _sliderDrawerKey =
        GlobalKey<SliderDrawerState>();

    final pages = [
      const TrendingScreen(),
      const HomeScreen(),
      const ProfileScreen(),
    ];
    return SafeArea(
      child: Scaffold(
        //  appBar: AppBar(backgroundColor: const Color.fromARGB(255, 24, 24, 24),),
        body: SliderDrawer(
          sliderOpenSize: 170,
          key: _sliderDrawerKey,
          isDraggable: false,
          slideDirection: SlideDirection.topToBottom,
          appBar: SliderAppBar(
            config: SliderAppBarConfig(
              backgroundColor: Color.fromARGB(255, 24, 24, 24),
              drawerIconColor: Colors.white,
              title: Text('data'),
            ),
          ),
          slider: Container(
            height: 170,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 24, 24, 24),
            ),
            child: MySlidderDrawer(),
          ),
          child: pages[currentIndex],
        ),
        bottomNavigationBar: BottomNavBar(
          title1: 'Trending',
          icon1: Icons.trending_up,
          title2: 'Home',
          icon2: Icons.home,
          title3: 'Profile',
          icon3: Icons.person,
        ),
      ),
    );
  }
}
