import 'dart:ui';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧠 APP INTRO
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _title("Culture Connect"),
                  SizedBox(height: 8),
                  _text(
                    "Culture Connect is a platform where people share their traditions, festivals, food, and stories — without chatting, just pure cultural expression 🌍.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 🎯 MISSION
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _title("Our Mission"),
                  SizedBox(height: 8),
                  _text(
                    "To connect people through culture and preserve traditions by sharing real experiences.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 🌍 VISION
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _title("Our Vision"),
                  SizedBox(height: 8),
                  _text(
                    "To become a global hub where cultures are celebrated, explored, and respected.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 👨‍💻 CREATOR
            _glassCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/images/logo.jpg"),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Karan Sharma",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Full Stack Developer",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 📱 APP INFO
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _title("App Info"),
                  SizedBox(height: 8),
                  _text("Version: 1.0.0"),
                  _text("Built with Flutter 💙"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧊 GLASS CARD
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 🔥 TITLE
class _title extends StatelessWidget {
  final String text;
  const _title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF5100),
      ),
    );
  }
}

/// 📄 TEXT
class _text extends StatelessWidget {
  final String text;
  const _text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, height: 1.5),
    );
  }
}
