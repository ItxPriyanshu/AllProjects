//NOT IN USE


import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 1; // start with Home
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _onTabChange,
            iconSize: 22,
            textSize: 20,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            mainAxisAlignment: MainAxisAlignment.center,
            color: const Color.fromARGB(255, 91, 181, 255),
            activeColor: Colors.black,
            tabBorderRadius: 16,
            tabActiveBorder: Border.all(color: Colors.blue, width: 2),
            tabBackgroundColor: const Color.fromARGB(255, 91, 181, 255),
            tabs: const [
              GButton(icon: Icons.leaderboard, text: 'Leaderboard'),
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.library_books, text: 'Library'),
            ],
          ), // <-- closes GNav
        ), // <-- closes Padding
      );
    
  }
}
