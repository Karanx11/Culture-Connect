import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:culture_frontend/components/about_us_screen.dart';
import 'package:culture_frontend/components/help_support_screen.dart';
import 'package:culture_frontend/components/terms_screen.dart';
import 'package:culture_frontend/screens/auth/login_screen.dart';
import 'package:culture_frontend/screens/notification_page.dart';

import 'profile/edit_profile_screen.dart';
import 'posts/add_post_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// 🔥 DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      /// POSTS
      final posts = await firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in posts.docs) {
        await firestore.collection('posts').doc(doc.id).delete();
      }

      /// STORIES
      final stories = await firestore
          .collection('stories')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in stories.docs) {
        await firestore.collection('stories').doc(doc.id).delete();
      }

      /// HIGHLIGHTS
      final highlights = await firestore
          .collection('highlights')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in highlights.docs) {
        await firestore.collection('highlights').doc(doc.id).delete();
      }

      /// FOLLOW CLEANUP
      final users = await firestore.collection('users').get();

      for (var doc in users.docs) {
        await firestore.collection('users').doc(doc.id).update({
          "followers": FieldValue.arrayRemove([uid]),
          "following": FieldValue.arrayRemove([uid]),
        });
      }

      /// NOTIFICATIONS
      final notifs = await firestore
          .collection('notifications')
          .where('toUserId', isEqualTo: uid)
          .get();

      for (var doc in notifs.docs) {
        await firestore.collection('notifications').doc(doc.id).delete();
      }

      /// USER DOC
      await firestore.collection('users').doc(uid).delete();

      /// AUTH DELETE
      await user.delete();

      /// NAVIGATION
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// 🔥 DELETE DIALOG
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F0A),
        title: const Text("Delete Account"),
        content: const Text(
          "This will permanently delete your account and all data.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAccount(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🔥 LOGOUT
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Account"),

          _glassTile(
            icon: Icons.person,
            title: "Edit Profile",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),

          _glassTile(
            icon: Icons.add_box,
            title: "Create Post",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle("App"),

          _glassTile(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle("Information"),

          _glassTile(
            icon: Icons.description,
            title: "Terms & Conditions",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),

          _glassTile(
            icon: Icons.info,
            title: "About Us",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),

          _glassTile(
            icon: Icons.help,
            title: "Help & Support",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 DELETE
          _glassTile(
            icon: Icons.delete_forever,
            title: "Delete Account",
            color: Colors.red,
            onTap: () => _showDeleteDialog(context),
          ),

          /// 🔥 LOGOUT
          _glassTile(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// 🔥 GLASS TILE
  Widget _glassTile({
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }
}
