import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sih_2k25/homepage.dart';
import 'package:sih_2k25/leaderboard.dart';
import 'package:sih_2k25/library_2.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final String userName; // add this

  const MainScreen({super.key, required this.token, required this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Leaderboard(),
          HomePage(
            token: widget.token,
            userName: widget.userName, // pass the actual username
          ),
           Library2(),
        ],
      ),
      bottomNavigationBar: Container(
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
            color: const Color.fromARGB(255, 26, 117, 245),
            activeColor: Colors.white,
            tabBorderRadius: 16,
            tabActiveBorder: Border.all(color: Colors.white, width: 2),
            tabBackgroundColor: const Color.fromARGB(255, 26, 117, 245),
            tabs: const [
              GButton(icon: Icons.leaderboard, text: 'Leaderboard'),
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.library_books, text: 'Library'),
            ],
          ),
        ),
      ),
    );
  }
}
