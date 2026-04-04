import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'profile_screen.dart';
import 'post_view_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  /// 🔥 CACHE USERS (performance boost)
  final Map<String, Map<String, dynamic>> userCache = {};

  /// 🔥 BATCH MARK ALL AS SEEN (optimized)
  Future<void> markAllSeen(List docs) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in docs) {
      if (!(doc['isSeen'] ?? false)) {
        batch.update(doc.reference, {"isSeen": true});
      }
    }

    await batch.commit();
  }

  /// 🔥 DELETE WITH CONFIRMATION
  Future<void> deleteNotification(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(id)
          .delete();
    }
  }

  /// 🔥 FETCH USER WITH CACHE
  Future<Map<String, dynamic>> getUser(String uid) async {
    if (userCache.containsKey(uid)) return userCache[uid]!;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};
    userCache[uid] = data;

    return data;
  }

  /// 🔥 GROUPING LOGIC
  String getGroupLabel(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "Earlier";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              final snap = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('toUserId', isEqualTo: currentUser)
                  .get();

              await markAllSeen(snap.docs);
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },

        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('toUserId', isEqualTo: currentUser)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            /// 🔄 LOADING STATE
            if (!snapshot.hasData) {
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => const ListTile(
                  leading: CircleAvatar(),
                  title: Text("Loading..."),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text("No notifications"));
            }

            /// mark seen automatically
            markAllSeen(docs);

            /// 🔥 GROUP DATA
            Map<String, List> grouped = {};

            for (var doc in docs) {
              final ts = doc['createdAt'];
              if (ts == null) continue;

              final time = ts.toDate();
              final label = getGroupLabel(time);

              grouped.putIfAbsent(label, () => []);
              grouped[label]!.add(doc);
            }

            final keys = grouped.keys.toList();

            return ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final label = keys[index];
                final items = grouped[label]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🏷️ SECTION TITLE
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    ...items.map((data) {
                      return FutureBuilder(
                        future: getUser(data['fromUserId']),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) {
                            return const ListTile(
                              leading: CircleAvatar(),
                              title: Text("Loading..."),
                            );
                          }

                          final user = userSnap.data!;
                          final isSeen = data['isSeen'] ?? false;

                          final time = data['createdAt'] != null
                              ? DateFormat(
                                  'hh:mm a',
                                ).format(data['createdAt'].toDate())
                              : "";

                          return Dismissible(
                            key: Key(data.id),
                            direction: DismissDirection.endToStart,

                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            onDismissed: (_) {
                              deleteNotification(data.id);
                            },

                            child: ListTile(
                              tileColor: isSeen
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.08),

                              leading: CircleAvatar(
                                backgroundImage:
                                    user['profileUrl'] != null &&
                                        user['profileUrl'].toString().isNotEmpty
                                    ? NetworkImage(user['profileUrl'])
                                    : null,
                                child: user['profileUrl'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),

                              title: Text(
                                "${user['username'] ?? "User"} ${data['text']}",
                                style: const TextStyle(fontSize: 14),
                              ),

                              subtitle: Text(
                                time,
                                style: const TextStyle(color: Colors.white70),
                              ),

                              onLongPress: () {
                                deleteNotification(data.id);
                              },

                              onTap: () {
                                if (data['type'] == "follow") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        userId: data['fromUserId'],
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PostViewScreen(data: data),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
