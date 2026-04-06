import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile/profile_screen.dart';
import 'posts/post_view_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  Timer? debounce;

  void onSearchChanged(String val) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        query = val.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(child: query.isEmpty ? _exploreGrid() : _searchResults()),
          ],
        ),
      ),
    );
  }

  /// 🔥 EXPLORE GRID
  Widget _exploreGrid() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return GridView.builder(
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
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
              child: Image.network(data['mediaUrl'], fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }

  /// 🔍 SEARCH USERS + POSTS
  Widget _searchResults() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where((doc) {
          final username = doc['username'].toString().toLowerCase();
          return username.contains(query);
        }).toList();

        return ListView(
          children: [
            /// USERS
            ...users.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['username']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: doc.id),
                    ),
                  );
                },
              );
            }),

            const Divider(),

            /// POSTS SEARCH
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();

                final posts = snap.data!.docs.where((doc) {
                  final caption = doc['caption'].toString().toLowerCase();
                  return caption.contains(query);
                }).toList();

                return Column(
                  children: posts.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['caption'] ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostViewScreen(data: data),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
