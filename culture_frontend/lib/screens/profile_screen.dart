import 'package:culture_frontend/screens/add_post_screen.dart';
import 'package:culture_frontend/screens/login_screen.dart';
import 'package:culture_frontend/screens/settings_screen.dart';
import 'package:culture_frontend/screens/edit_profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // 👈 IMPORTANT (for other users)

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String username = "";
  String bio = "";
  String profileUrl = "";
  String coverUrl = "";

  List followers = [];
  List following = [];

  bool isLoading = true;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String get profileUserId =>
      widget.userId ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// 🔥 FETCH USER
  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(profileUserId)
        .get();

    final data = doc.data()!;

    setState(() {
      name = data['name'] ?? "";
      username = data['username'] ?? "";
      bio = data['bio'] ?? "";
      profileUrl = data['profileUrl'] ?? "";
      coverUrl = data['coverUrl'] ?? "";

      followers = data['followers'] ?? [];
      following = data['following'] ?? [];

      isLoading = false;
    });
  }

  /// 🔥 FOLLOW SYSTEM
  Future<void> toggleFollow() async {
    final currentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId);

    final targetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(profileUserId);

    if (followers.contains(currentUserId)) {
      await targetRef.update({
        "followers": FieldValue.arrayRemove([currentUserId]),
      });

      await currentRef.update({
        "following": FieldValue.arrayRemove([profileUserId]),
      });
    } else {
      await targetRef.update({
        "followers": FieldValue.arrayUnion([currentUserId]),
      });

      await currentRef.update({
        "following": FieldValue.arrayUnion([profileUserId]),
      });
    }

    fetchUserData(); // refresh
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = profileUserId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: _openCreatePost,
                ),
                IconButton(icon: const Icon(Icons.menu), onPressed: _openMenu),
              ]
            : [],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// COVER
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: coverUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(coverUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey,
                  ),
                ),

                /// PROFILE
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : null,
                ),

                const SizedBox(height: 10),

                Text(name, style: const TextStyle(fontSize: 18)),
                Text("@$username"),
                Text(bio),

                const SizedBox(height: 10),

                /// FOLLOW / EDIT BUTTON
                isOwnProfile
                    ? ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          fetchUserData();
                        },
                        child: const Text("Edit Profile"),
                      )
                    : ElevatedButton(
                        onPressed: toggleFollow,
                        child: Text(
                          followers.contains(currentUserId)
                              ? "Unfollow"
                              : "Follow",
                        ),
                      ),

                const SizedBox(height: 15),

                /// STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat("Posts", "12"),
                    _stat("Followers", followers.length.toString()),
                    _stat("Following", following.length.toString()),
                  ],
                ),
              ],
            ),
    );
  }

  /// STAT UI
  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Settings"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          ListTile(
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
