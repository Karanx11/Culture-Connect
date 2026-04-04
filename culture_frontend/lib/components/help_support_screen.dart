import 'dart:ui';
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ❓ FAQ
          _sectionTitle("Frequently Asked Questions"),
          _faqTile(
            "How to create a post?",
            "Go to the + button and upload your cultural content.",
          ),
          _faqTile(
            "How to edit profile?",
            "Go to profile → settings → edit profile.",
          ),
          _faqTile(
            "How to add story?",
            "Tap on 'Your Story' from home screen.",
          ),

          const SizedBox(height: 20),

          /// 📩 CONTACT
          _sectionTitle("Contact Support"),
          _tile(
            icon: Icons.email,
            title: "Email Support",
            subtitle: "support@cultureconnect.com",
            onTap: () {
              _showSnack(context, "Opening email...");
            },
          ),

          _tile(
            icon: Icons.phone,
            title: "Call Support",
            subtitle: "+91 98765 43210",
            onTap: () {
              _showSnack(context, "Calling support...");
            },
          ),

          const SizedBox(height: 20),

          /// 🐞 REPORT
          _sectionTitle("Report an Issue"),
          _tile(
            icon: Icons.bug_report,
            title: "Report Bug",
            onTap: () {
              _showSnack(context, "Report feature coming soon");
            },
          ),

          _tile(
            icon: Icons.feedback,
            title: "Send Feedback",
            onTap: () {
              _showSnack(context, "Feedback feature coming soon");
            },
          ),
        ],
      ),
    );
  }

  /// 🔥 SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  /// ❓ FAQ TILE
  Widget _faqTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ExpansionTile(
              title: Text(question),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    answer,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🧊 TILE
  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              leading: Icon(icon, color: const Color(0xFFFF5100)),
              title: Text(title),
              subtitle: subtitle != null ? Text(subtitle) : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  /// 📩 SNACK
  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
