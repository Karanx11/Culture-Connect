import 'dart:ui';
import 'package:culture_frontend/components/about_us_screen.dart';
import 'package:culture_frontend/components/help_support_screen.dart';
import 'package:culture_frontend/components/terms_screen.dart';
import 'package:culture_frontend/screens/notification_page.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'add_post_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 👤 ACCOUNT SECTION
          _sectionTitle("Account"),
          _tile(
            icon: Icons.person,
            title: "Edit Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          _tile(
            icon: Icons.add_box,
            title: "Create Post",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          /// APP SETTINGS
          _sectionTitle("App"),
          _tile(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          _tile(
            icon: Icons.lock,
            title: "Privacy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          /// 📄 INFO SECTION
          _sectionTitle("Information"),
          _tile(
            icon: Icons.description,
            title: "Terms & Conditions",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
          ),
          _tile(
            icon: Icons.info,
            title: "About Us",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              );
            },
          ),
          _tile(
            icon: Icons.help,
            title: "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          /// 🚪 LOGOUT
          _tile(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
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
          color: Colors.white70,
        ),
      ),
    );
  }

  /// 🧊 GLASS TILE
  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
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
              leading: Icon(icon, color: color),
              title: Text(title),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  /// ⚠️ LOGOUT CONFIRM
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F0A),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
