import 'dart:ui';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SectionTitle("Welcome"),
                    _SectionText(
                      "Welcome to Culture Connect. By using our app, you agree to these terms and conditions.",
                    ),

                    _SectionTitle("User Content"),
                    _SectionText(
                      "Users are responsible for the content they upload. Content must respect cultural values and community guidelines.",
                    ),

                    _SectionTitle("Privacy"),
                    _SectionText(
                      "We respect your privacy. Your data is securely handled and not shared without your consent.",
                    ),

                    _SectionTitle("Prohibited Activities"),
                    _SectionText(
                      "Do not post harmful, offensive, or illegal content. Violations may lead to account suspension.",
                    ),

                    _SectionTitle("Termination"),
                    _SectionText(
                      "We reserve the right to terminate accounts that violate our policies.",
                    ),

                    _SectionTitle("Changes to Terms"),
                    _SectionText(
                      "We may update these terms at any time. Continued use means you accept the updated terms.",
                    ),

                    _SectionTitle("Contact Us"),
                    _SectionText(
                      "If you have any questions, contact us at support@cultureconnect.com",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔥 TITLE
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF5100),
        ),
      ),
    );
  }
}

/// 📄 TEXT
class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, height: 1.5),
    );
  }
}
