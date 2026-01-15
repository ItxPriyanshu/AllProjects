import 'package:dropnote/providers/onscreen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class BottomNavBar extends ConsumerWidget {
  final String title1;
  final String title2;
  final String title3;

  final IconData icon1;
  final IconData icon2;
  final IconData icon3;


  const BottomNavBar({
  super.key,
  required this.title1,
  required this.title2,
  required this.title3,
  required this.icon1,
  required this.icon2,
  required this.icon3,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.lightGreenAccent.withAlpha(50),
            offset: Offset(0, 4),
            blurRadius: 20.0
          )
        ]
      ),
      child: SlidingClippedNavBar(
        
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        barItems: [
        BarItem(title: title1, icon: icon1),
        BarItem(title: title2, icon: icon2),
        BarItem(title: title3, icon: icon3),
      ], selectedIndex: currentIndex, onButtonPressed: (index){
        ref.read(bottomNavIndexProvider.notifier).state=index;
      }, activeColor: Colors.lightGreenAccent),
    );
  }
}