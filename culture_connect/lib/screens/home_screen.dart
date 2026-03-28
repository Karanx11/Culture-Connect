import 'package:culture_connect/components/add_story_page.dart';
import 'package:culture_connect/components/notification_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> liked = List.generate(10, (_) => false);

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

                  /// 🔔 NOTIFICATION
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_none),

                        /// 🔥 BADGE
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5100),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "3",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 📸 STORIES
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _storyItem(index);
                },
              ),
            ),

            const Divider(color: Colors.white24),

            /// 📰 POSTS
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _postItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📸 STORY ITEM
  Widget _storyItem(int index) {
    final isFirst = index == 0;

    return GestureDetector(
      onTap: () {
        if (isFirst) {
          /// ➕ ADD STORY
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStoryScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Open story $index")));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Stack(
              children: [
                /// 🔵 STORY RING
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isFirst
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFFF5100), Color(0xFF8A2E00)],
                          ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),

                /// ➕ ADD STORY ICON
                if (isFirst)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              isFirst ? "Your Story" : "User $index",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 📰 POST ITEM
  Widget _postItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        ListTile(
          leading: const CircleAvatar(),
          title: Text("user_$index"),
          subtitle: const Text("Bihar"),
          trailing: const Icon(Icons.more_vert),
        ),

        /// IMAGE
        GestureDetector(
          onDoubleTap: () {
            setState(() => liked[index] = true);
          },
          child: Container(height: 250, color: const Color(0xFFFF5100)),
        ),

        /// ACTIONS
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  liked[index] = !liked[index];
                });
              },
              icon: Icon(
                liked[index] ? Icons.favorite : Icons.favorite_border,
                color: liked[index] ? Colors.red : Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.comment_outlined),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
          ],
        ),

        /// CAPTION
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "This is a cultural post ❤️",
            style: TextStyle(color: Colors.white70),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}
