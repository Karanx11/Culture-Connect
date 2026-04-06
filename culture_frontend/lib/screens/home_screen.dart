import 'package:culture_frontend/components/stories/add_story_page.dart';
import 'package:culture_frontend/components/stories/story_viewr_advanced.dart';
import 'package:culture_frontend/screens/notification_page.dart';
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

/// 🎥 VIDEO PLAYER
class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() => isReady = true);
        controller.setLooping(true);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: VideoPlayer(controller),
    );
  }
}

/// 🔥 HOME SCREEN
class _HomeScreenState extends State<HomeScreen> {
  bool _showBigHeart = false;

  void _showHeart() {
    setState(() => _showBigHeart = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _showBigHeart = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Culture Connect",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  /// 🔔 NOTIFICATIONS
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where(
                            'toUserId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                          )
                          .where('isSeen', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        int count = snapshot.hasData
                            ? snapshot.data!.docs.length
                            : 0;

                        return Stack(
                          children: [
                            const Icon(Icons.notifications_none),
                            if (count > 0)
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
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

                  Map<String, List> grouped = {};

                  for (var doc in docs) {
                    final uid = doc['uid'];
                    grouped.putIfAbsent(uid, () => []);
                    grouped[uid]!.add(doc);
                  }

                  final users = grouped.keys.toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _addStoryItem();

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

  /// ➕ ADD STORY
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

  /// 📸 STORY ITEM (Seen/Unseen)
  Widget _storyItem(List stories) {
    final first = stories[0];
    final userId = FirebaseAuth.instance.currentUser!.uid;

    bool isSeen = true;

    for (var story in stories) {
      final data = story.data() as Map<String, dynamic>;
      List viewers = data['viewers'] ?? [];

      if (!viewers.contains(userId)) {
        isSeen = false;
        break;
      }
    }

    return GestureDetector(
      onTap: () async {
        for (var story in stories) {
          final data = story.data() as Map<String, dynamic>;
          final viewers = data['viewers'] ?? [];

          if (!viewers.contains(userId)) {
            await FirebaseFirestore.instance
                .collection('stories')
                .doc(story.id)
                .update({
                  'viewers': FieldValue.arrayUnion([userId]),
                });
          }
        }

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSeen
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFF5100), Color(0xFF8A2E00)],
                      ),
                color: isSeen ? Colors.grey : null,
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

  /// ❤️ LIKE + NOTIFICATION
  Future<void> _toggleLike(String postId, Map data) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('posts').doc(postId);

    final alreadyLiked = (data['likes'] ?? []).contains(userId);

    if (alreadyLiked) {
      await ref.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([userId]),
      });

      if (data['uid'] != userId) {
        await sendNotification(
          toUserId: data['uid'],
          text: "liked your post",
          type: "like",
          postId: postId,
        );
      }
    }
  }

  /// 📰 POST ITEM
  Widget _postItem(QueryDocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = (data['likes'] ?? []).contains(userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: data['profileUrl'] != null
                ? NetworkImage(data['profileUrl'])
                : null,
            child: data['profileUrl'] == null ? const Icon(Icons.person) : null,
          ),
          title: Text(data['username'] ?? ""),
          subtitle: Text(data['location'] ?? ""),
        ),

        /// ❤️ MEDIA WITH DOUBLE TAP
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onDoubleTap: () async {
                await _toggleLike(post.id, data);
                _showHeart();
              },
              child: data['type'] == "video"
                  ? _videoPlayer(data['mediaUrl'])
                  : Image.network(
                      data['mediaUrl'],
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            AnimatedOpacity(
              opacity: _showBigHeart ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.favorite, color: Colors.white, size: 100),
            ),
          ],
        ),

        Row(
          children: [
            IconButton(
              onPressed: () => _toggleLike(post.id, data),
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => _openComments(post.id, data['uid']),
              icon: const Icon(Icons.comment_outlined),
            ),
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("${(data['likes'] ?? []).length} likes"),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(data['caption'] ?? ""),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  /// 💬 COMMENTS
  void _openComments(String postId, String postOwnerId) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Column(
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
                      itemBuilder: (_, i) {
                        final c = comments[i];
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

                      final user = FirebaseAuth.instance.currentUser!;
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
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

                      if (postOwnerId != user.uid) {
                        await sendNotification(
                          toUserId: postOwnerId,
                          text: "commented on your post",
                          type: "comment",
                          postId: postId,
                        );
                      }

                      controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔔 NOTIFICATION
  Future<void> sendNotification({
    required String toUserId,
    required String text,
    required String type,
    String? postId,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance.collection('notifications').add({
      "toUserId": toUserId,
      "fromUserId": user.uid,
      "text": text,
      "type": type,
      "postId": postId,
      "isSeen": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// 🎥 VIDEO
  Widget _videoPlayer(String url) {
    return VideoPlayerWidget(url: url);
  }
}
