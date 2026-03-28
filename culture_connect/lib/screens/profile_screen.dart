import 'package:culture_connect/screens/add_post_screen.dart';
import 'package:culture_connect/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  /// 🔥 CHANGE THIS LATER (backend)
  bool hasPosts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      /// 🔝 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("karan_x11"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _openCreatePost(),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _openMenu(),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 👤 PROFILE HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openCreatePost,
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/logo.jpg"),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatItem("12", "Posts"),
                        _StatItem("340", "Followers"),
                        _StatItem("180", "Following"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// NAME + BIO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Karan Sharma",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Culture Explorer 🌍",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// EDIT PROFILE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5100),
                ),
                onPressed: () {},
                child: const Text("Edit Profile"),
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 STORY HIGHLIGHTS
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _highlight("Festivals"),
                  _highlight("Food"),
                  _highlight("Dance"),
                ],
              ),
            ),

            const Divider(),

            /// TABS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: selectedTab == 0 ? Colors.white : Colors.white38,
                  ),
                  onPressed: () => setState(() => selectedTab = 0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.video_collection,
                    color: selectedTab == 1 ? Colors.white : Colors.white38,
                  ),
                  onPressed: () => setState(() => selectedTab = 1),
                ),
              ],
            ),

            /// CONTENT
            selectedTab == 0
                ? _buildGrid()
                : const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Reels coming soon..."),
                  ),
          ],
        ),
      ),
    );
  }

  /// 📸 GRID OR EMPTY STATE
  Widget _buildGrid() {
    if (!hasPosts) {
      return Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.add_a_photo, size: 50, color: Colors.white54),
          const SizedBox(height: 10),
          const Text("No posts yet", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5100),
            ),
            onPressed: _openCreatePost,
            child: const Text("Create Your First Post"),
          ),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostViewerScreen(index: index)),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            color: const Color(0xFFFF5100),
          ),
        );
      },
    );
  }

  /// 🔘 HIGHLIGHT → CREATE POST
  Widget _highlight(String text) {
    return GestureDetector(
      onTap: _openCreatePost,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            const CircleAvatar(radius: 28),
            const SizedBox(height: 5),
            Text(text),
          ],
        ),
      ),
    );
  }

  /// 🔥 OPEN CREATE POST
  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  /// 📂 MENU
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
            onTap: () => Navigator.pop(context),
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

/// 🖼 POST VIEWER
class PostViewerScreen extends StatefulWidget {
  final int index;
  const PostViewerScreen({super.key, required this.index});

  @override
  State<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends State<PostViewerScreen> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post ${widget.index}")),
      body: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFFF5100))),
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : null,
            ),
            onPressed: () => setState(() => liked = !liked),
          ),
        ],
      ),
    );
  }
}
