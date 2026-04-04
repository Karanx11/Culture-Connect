import 'package:culture_frontend/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListScreen extends StatefulWidget {
  final List userIds;
  final String title;

  const UserListScreen({super.key, required this.userIds, required this.title});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List following = [];

  @override
  void initState() {
    super.initState();
    fetchFollowing();
  }

  /// 🔥 GET CURRENT USER FOLLOWING
  Future<void> fetchFollowing() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    setState(() {
      following = doc['following'] ?? [];
    });
  }

  /// 🔥 FOLLOW / UNFOLLOW
  Future<void> toggleFollow(String targetUserId) async {
    final currentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId);

    final targetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId);

    if (following.contains(targetUserId)) {
      /// UNFOLLOW
      await currentRef.update({
        "following": FieldValue.arrayRemove([targetUserId]),
      });

      await targetRef.update({
        "followers": FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      /// FOLLOW
      await currentRef.update({
        "following": FieldValue.arrayUnion([targetUserId]),
      });

      await targetRef.update({
        "followers": FieldValue.arrayUnion([currentUserId]),
      });
    }

    fetchFollowing(); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),

      body: widget.userIds.isEmpty
          ? const Center(child: Text("No users"))
          : ListView.builder(
              itemCount: widget.userIds.length,
              itemBuilder: (context, index) {
                final userId = widget.userIds[index];

                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(title: Text("Loading..."));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    final isFollowing = following.contains(userId);

                    final isMe = userId == currentUserId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            data['profileUrl'] != null &&
                                data['profileUrl'].toString().isNotEmpty
                            ? NetworkImage(data['profileUrl'])
                            : null,
                        child: data['profileUrl'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),

                      title: Text(data['username'] ?? ""),
                      subtitle: Text(data['name'] ?? ""),

                      /// 🔥 FOLLOW BUTTON
                      trailing: isMe
                          ? null
                          : ElevatedButton(
                              onPressed: () => toggleFollow(userId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? Colors.grey
                                    : const Color(0xFFFF5100),
                              ),
                              child: Text(isFollowing ? "Unfollow" : "Follow"),
                            ),

                      /// OPEN PROFILE
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(userId: userId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
