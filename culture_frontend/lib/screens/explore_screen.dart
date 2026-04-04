import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
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

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return ReelItem(
                  post: posts[index],
                  isActive: index == currentIndex,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final QueryDocumentSnapshot post;
  final bool isActive;

  const ReelItem({super.key, required this.post, required this.isActive});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> data;

  late VideoPlayerController controller;

  bool isReady = false;
  bool showHeart = false;

  late AnimationController heartController;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    data = widget.post.data() as Map<String, dynamic>;

    /// ❤️ animation
    heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    scaleAnim = Tween(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(parent: heartController, curve: Curves.elasticOut),
    );

    /// 🎥 video init
    if (data['type'] == "video") {
      controller = VideoPlayerController.network(data['mediaUrl'])
        ..initialize().then((_) {
          if (!mounted) return;

          setState(() => isReady = true);
          controller.setLooping(true);

          if (widget.isActive) controller.play();
        });
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// ▶️ AUTO PLAY / PAUSE
    if (data['type'] == "video" && isReady) {
      if (widget.isActive) {
        controller.play();
      } else {
        controller.pause();
      }
    }
  }

  @override
  void dispose() {
    if (data['type'] == "video") controller.dispose();
    heartController.dispose();
    super.dispose();
  }

  /// ❤️ LIKE + ANIMATION
  void _likePost() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);

    final likes = List.from(data['likes'] ?? []);

    if (!likes.contains(userId)) {
      await ref.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }

    setState(() => showHeart = true);
    heartController.forward().then((_) {
      heartController.reverse();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => showHeart = false);
      });
    });
  }

  /// 👤 FOLLOW SYSTEM
  Future<void> _followUser() async {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    final targetUser = data['uid'];

    final ref = FirebaseFirestore.instance.collection('users');

    await ref.doc(currentUser).update({
      "following": FieldValue.arrayUnion([targetUser]),
    });

    await ref.doc(targetUser).update({
      "followers": FieldValue.arrayUnion([currentUser]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final likes = List.from(data['likes'] ?? []);
    final isLiked = likes.contains(userId);

    return GestureDetector(
      onDoubleTap: _likePost,

      child: Stack(
        children: [
          /// 🎬 MEDIA
          Positioned.fill(
            child: data['type'] == "video"
                ? (isReady
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPlayer(controller),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()))
                : Image.network(data['mediaUrl'], fit: BoxFit.cover),
          ),

          /// ❤️ HEART ANIMATION
          if (showHeart)
            Center(
              child: ScaleTransition(
                scale: scaleAnim,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),

          /// 👇 GLASS BOX
          Positioned(
            bottom: 90,
            left: 12,
            right: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USERNAME + FOLLOW
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileScreen(userId: data['uid']),
                                ),
                              );
                            },
                            child: Text(
                              "@${data['username']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _followUser,
                            child: const Text("Follow"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        data['caption'] ?? "",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ACTIONS
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: _likePost,
                ),
                Text(
                  "${likes.length}",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 10),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data['mediaUrl']));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
