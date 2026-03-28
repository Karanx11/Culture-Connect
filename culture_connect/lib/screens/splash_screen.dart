import 'package:culture_connect/components/bottom_navigation_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 MAIN CONTENT
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 🧠 LOGO
                  Image.asset("assets/images/logo.jpg", height: 120),

                  const SizedBox(height: 25),

                  /// 🔄 LOADING
                  const CircularProgressIndicator(color: Color(0xFFFF5100)),

                  const SizedBox(height: 25),

                  /// 💬 QUOTE
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Discover traditions, share stories, connect cultures 🌍",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🚀 BUTTON
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      },
                      child: const Text(
                        "Explore The Culture",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 👇 BOTTOM CREDIT
            const Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                "Built by Karan",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
