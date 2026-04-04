import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHighlightScreen extends StatefulWidget {
  const AddHighlightScreen({super.key});

  @override
  State<AddHighlightScreen> createState() => _AddHighlightScreenState();
}

class _AddHighlightScreenState extends State<AddHighlightScreen> {
  List selectedStories = [];
  final titleController = TextEditingController();

  File? coverImage;
  final picker = ImagePicker();

  Future<void> pickCover() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => coverImage = File(picked.path));
    }
  }

  /// ⚠️ Replace with your Cloudinary upload
  Future<String> uploadImage(File file) async {
    // TODO: your Cloudinary upload function
    return "https://dummyurl.com/image.jpg";
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("New Highlight")),

      body: Column(
        children: [
          /// 🔥 COVER PICKER
          GestureDetector(
            onTap: pickCover,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: coverImage != null
                  ? FileImage(coverImage!)
                  : null,
              child: coverImage == null ? const Icon(Icons.add_a_photo) : null,
            ),
          ),

          const SizedBox(height: 10),

          /// TITLE
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Highlight title"),
          ),

          /// STORIES GRID
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  .where('uid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stories = snapshot.data!.docs;

                return GridView.builder(
                  itemCount: stories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    final data = stories[index];

                    final isSelected = selectedStories.contains(
                      data['imageUrl'],
                    );

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? selectedStories.remove(data['imageUrl'])
                              : selectedStories.add(data['imageUrl']);
                        });
                      },
                      child: Stack(
                        children: [
                          Image.network(data['imageUrl'], fit: BoxFit.cover),
                          if (isSelected)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Icon(Icons.check),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              if (selectedStories.isEmpty) return;

              String coverUrl = selectedStories[0];

              if (coverImage != null) {
                coverUrl = await uploadImage(coverImage!);
              }

              await FirebaseFirestore.instance.collection('highlights').add({
                "uid": userId,
                "title": titleController.text.trim(),
                "coverImage": coverUrl,
                "storyUrls": selectedStories,
                "order": DateTime.now().millisecondsSinceEpoch,
                "createdAt": FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
