import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? image;
  final picker = ImagePicker();

  final TextEditingController captionController = TextEditingController();

  bool isUploading = false;

  final cloudName = "ddkmxxkf8";

  /// 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    pickImage();
  }

  /// ☁️ CLOUDINARY UPLOAD
  Future<String> uploadImage(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = 'culture_upload';

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    final data = jsonDecode(res.body);

    return data['secure_url'];
  }

  /// 🚀 SHARE STORY
  Future<void> shareStory() async {
    if (image == null) return;

    setState(() => isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      /// upload image
      final imageUrl = await uploadImage(image!);

      /// get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data()!;

      /// save story
      await FirebaseFirestore.instance.collection('stories').add({
        "uid": user.uid,
        "username": userData['username'],
        "profileUrl": userData['profileUrl'],
        "imageUrl": imageUrl,
        "caption": captionController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
        "expiresAt": Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Story added 🚀")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isUploading ? null : shareStory,
            child: isUploading
                ? const CircularProgressIndicator(color: Colors.orange)
                : const Text(
                    "Share",
                    style: TextStyle(
                      color: Color(0xFFFF5100),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),

      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(child: Image.file(image!, fit: BoxFit.cover)),

                /// CAPTION
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: TextField(
                    controller: captionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add a caption...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// CHANGE IMAGE
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFFFF5100),
                    onPressed: pickImage,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
    );
  }
}
