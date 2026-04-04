import 'package:culture_frontend/components/add_story_page.dart';
import 'package:culture_frontend/components/story_viewr_advanced.dart';
import 'package:culture_frontend/screens/notification_page.dart';
import 'package:culture_frontend/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Culture Connect",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
            ),

            /// 📸 STORIES
            SizedBox(
              height: 110,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  /// GROUP BY USER
                  Map<String, List> grouped = {};

                  for (var doc in docs) {
                    final uid = doc['uid'];

                    if (!grouped.containsKey(uid)) {
                      grouped[uid] = [];
                    }

                    grouped[uid]!.add(doc);
                  }

                  final users = grouped.keys.toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length + 1,
                    itemBuilder: (context, index) {
                      /// ➕ ADD STORY
                      if (index == 0) {
                        return _addStoryItem();
                      }

                      final userStories = grouped[users[index - 1]]!;

                      return _storyItem(userStories);
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white24),

            /// 📰 POSTS
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs;

                  if (posts.isEmpty) {
                    return const Center(child: Text("No posts yet"));
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _postItem(posts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 ADD STORY
  Widget _addStoryItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddStoryScreen()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            CircleAvatar(radius: 32),
            SizedBox(height: 5),
            Text("Your Story", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// 🔥 STORY ITEM
  Widget _storyItem(List stories) {
    final first = stories[0];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewerAdvanced(stories: stories),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5100), Color(0xFF8A2E00)],
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(first['profileUrl']),
              ),
            ),
            const SizedBox(height: 5),
            Text(first['username'], style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// 🔥 POST ITEM
  Widget _postItem(QueryDocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = (data['likes'] ?? []).contains(userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: data['uid']),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data['profileUrl'] ?? ""),
              ),
              title: Text(data['username'] ?? ""),
              subtitle: Text(data['location'] ?? ""),
            ),
          ),

          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: data['uid']),
                ),
              );
            },
            child: Text(data['username'] ?? ""),
          ),

          subtitle: Text(data['location'] ?? ""),
          trailing: const Icon(Icons.more_vert),
        ),

        /// MEDIA
        GestureDetector(
          onDoubleTap: () => _toggleLike(post.id, data),
          child: data['type'] == "video"
              ? _videoPlayer(data['mediaUrl'])
              : Image.network(
                  data['mediaUrl'],
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),

        /// ACTIONS
        Row(
          children: [
            IconButton(
              onPressed: () => _toggleLike(post.id, data),
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
              ),
            ),

            /// 💬 COMMENT
            IconButton(
              onPressed: () => _openComments(post.id),
              icon: const Icon(Icons.comment_outlined),
            ),

            /// 📤 SHARE
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data['mediaUrl']));

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Link copied")));
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),

        /// LIKES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "${(data['likes'] ?? []).length} likes",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        /// CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(data['caption'] ?? ""),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  /// ❤️ LIKE FUNCTION
  Future<void> _toggleLike(String postId, Map data) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseFirestore.instance.collection('posts').doc(postId);

    if ((data['likes'] ?? []).contains(userId)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  /// 💬 COMMENTS
  void _openComments(String postId) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return ListTile(
                        title: Text(c['username']),
                        subtitle: Text(c['text']),
                      );
                    },
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Add comment...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    final user = FirebaseAuth.instance.currentUser;

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .get();

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .add({
                          "text": controller.text.trim(),
                          "username": userDoc['username'],
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                    controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 🎥 VIDEO PLAYER
  Widget _videoPlayer(String url) {
    final controller = VideoPlayerController.network(url);

    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        controller.setLooping(true);
        controller.play();

        return SizedBox(height: 300, child: VideoPlayer(controller));
      },
    );
  }
}
