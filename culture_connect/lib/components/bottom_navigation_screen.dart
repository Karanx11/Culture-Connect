import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:culture_connect/screens/add_post_screen.dart';
import 'package:culture_connect/screens/explore_screen.dart';
import 'package:culture_connect/screens/home_screen.dart';
import 'package:culture_connect/screens/profile_screen.dart';
import 'package:culture_connect/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final PageController _pageController = PageController();

  final List<Widget> screens = const [
    HomeScreen(),
    ExploreScreen(),
    CreatePostScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      body: Stack(
        children: [
          /// 🔥 SWIPEABLE PAGES
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            children: screens,
          ),

          /// 🧊 FLOATING NAVBAR
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home, 0),
                      _navItem(Icons.explore, 1),

                      /// ➕ ADD BUTTON
                      GestureDetector(
                        onTap: () => _goToPage(2),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: currentIndex == 2
                                ? const Color(0xFFFF5100)
                                : Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: currentIndex == 2
                                ? Colors.white
                                : Colors.white70,
                            size: 28,
                          ),
                        ),
                      ),

                      _navItem(Icons.search, 3),
                      _navItem(Icons.person, 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 NAV ITEM
  Widget _navItem(IconData icon, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _goToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFF5100).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFFF5100) : Colors.white70,
          size: 26,
        ),
      ),
    );
  }

  /// 🚀 NAVIGATION FUNCTION
  void _goToPage(int index) {
    setState(() => currentIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
