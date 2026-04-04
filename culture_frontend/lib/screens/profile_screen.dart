import 'package:culture_frontend/screens/add_highligh_screen.dart';
import 'package:culture_frontend/screens/add_post_screen.dart';
import 'package:culture_frontend/screens/highlight_viewer.dart';
import 'package:culture_frontend/screens/login_screen.dart';
import 'package:culture_frontend/screens/settings_screen.dart';
import 'package:culture_frontend/screens/edit_profile_screen.dart';
import 'package:culture_frontend/screens/post_view_screen.dart';
import 'package:culture_frontend/screens/user_list_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String name = "";
  String username = "";
  String bio = "";
  String profileUrl = "";
  String coverUrl = "";

  List followers = [];
  List following = [];

  int postCount = 0;

  bool isLoading = true;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late TabController _tabController;

  String get profileUserId =>
      widget.userId ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserData();
  }

  /// 🔥 FETCH USER DATA
  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(profileUserId)
        .get();

    final data = doc.data()!;

    final posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: profileUserId)
        .get();

    setState(() {
      name = data['name'] ?? "";
      username = data['username'] ?? "";
      bio = data['bio'] ?? "";
      profileUrl = data['profileUrl'] ?? "";
      coverUrl = data['coverUrl'] ?? "";

      followers = data['followers'] ?? [];
      following = data['following'] ?? [];

      postCount = posts.docs.length;

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

    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = profileUserId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: Text(username),
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
                /// 🔥 HEADER
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 150,
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

                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: profileUrl.isNotEmpty
                            ? NetworkImage(profileUrl)
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "@$username",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(bio),
                SizedBox(
                  height: 100,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('highlights')
                        .where('uid', isEqualTo: profileUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final highlights = snapshot.data!.docs;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: highlights.length + 1,
                        itemBuilder: (context, index) {
                          /// ➕ ADD
                          if (index == 0) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddHighlightScreen(),
                                  ),
                                );
                              },
                              child: const Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    child: Icon(Icons.add),
                                  ),
                                  Text("New"),
                                ],
                              ),
                            );
                          }

                          final data = highlights[index - 1];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HighlightViewer(
                                    stories: List<String>.from(
                                      data['storyUrls'],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      data['coverImage'],
                                    ),
                                  ),
                                  Text(data['title']),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /// 🔥 BUTTON
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

                const SizedBox(height: 10),

                /// 🔥 STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat("Posts", postCount.toString()),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserListScreen(
                              userIds: followers,
                              title: "Followers",
                            ),
                          ),
                        );
                      },
                      child: _stat("Followers", followers.length.toString()),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserListScreen(
                              userIds: following,
                              title: "Following",
                            ),
                          ),
                        );
                      },
                      child: _stat("Following", following.length.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 🔥 TABS
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.video_collection)),
                  ],
                ),

                /// 🔥 CONTENT
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildPostsGrid(false), _buildPostsGrid(true)],
                  ),
                ),
              ],
            ),
    );
  }

  /// 🔥 POSTS GRID
  Widget _buildPostsGrid(bool isVideo) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: profileUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs.where((doc) {
          return isVideo ? doc['type'] == "video" : doc['type'] == "image";
        }).toList();

        if (posts.isEmpty) {
          return const Center(child: Text("No posts"));
        }

        return GridView.builder(
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostViewScreen(data: data)),
                );
              },
              child: data['type'] == "video"
                  ? Stack(
                      children: [
                        Image.network(
                          data['mediaUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        const Center(child: Icon(Icons.play_arrow)),
                      ],
                    )
                  : Image.network(data['mediaUrl'], fit: BoxFit.cover),
            );
          },
        );
      },
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
