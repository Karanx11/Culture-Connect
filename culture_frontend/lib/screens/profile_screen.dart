import 'package:culture_frontend/screens/add_post_screen.dart';
import 'package:culture_frontend/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  String name = "";
  String username = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔥 FETCH USER DATA
  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? "";
          username = doc['username'] ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _openCreatePost,
          ),
          IconButton(icon: const Icon(Icons.menu), onPressed: _openMenu),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔥 PROFILE CARD
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF241510),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          /// COVER + PROFILE
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 120,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF5100),
                                      Color(0xFF1A0F0A),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: -40,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF241510),
                                        width: 4,
                                      ),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage(
                                        "assets/images/logo.jpg",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 50),

                          /// 🔥 DYNAMIC NAME
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// 🔥 DYNAMIC USERNAME
                          Text(
                            "@$username",
                            style: const TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 12),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem("12", "Posts"),
                              _StatItem("340", "Followers"),
                              _StatItem("180", "Following"),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  /// POSTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.grid_on,
                          color: selectedTab == 0
                              ? Colors.white
                              : Colors.white38,
                        ),
                        onPressed: () => setState(() => selectedTab = 0),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.video_collection,
                          color: selectedTab == 1
                              ? Colors.white
                              : Colors.white38,
                        ),
                        onPressed: () => setState(() => selectedTab = 1),
                      ),
                    ],
                  ),

                  selectedTab == 0
                      ? _buildGrid()
                      : const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Videos coming soon..."),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(2),
          color: const Color(0xFFFF5100),
        );
      },
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// 📊 STAT
class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
