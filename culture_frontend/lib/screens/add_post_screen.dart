import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? image;
  File? video;

  VideoPlayerController? videoController;

  final picker = ImagePicker();

  int selectedType = 0; // 0 = image, 1 = video

  final captionController = TextEditingController();
  final locationController = TextEditingController();

  bool isUploading = false;

  final cloudName = "ddkmxxkf8";

  /// 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
        video = null;
      });
    }
  }

  /// 🎥 PICK VIDEO
  Future<void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      video = File(picked.path);
      videoController = VideoPlayerController.file(video!)
        ..initialize().then((_) {
          setState(() {});
          videoController!.setLooping(true);
          videoController!.play();
        });

      image = null;
      setState(() {});
    }
  }

  /// ☁️ CLOUDINARY UPLOAD
  Future<String> uploadFile(File file, bool isVideo) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? "video" : "image"}/upload",
    );

    final request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = 'culture_upload';

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    final data = jsonDecode(res.body);

    return data['secure_url'];
  }

  /// 🚀 CREATE POST
  Future<void> createPost() async {
    if (selectedType == 0 && image == null) {
      _showMsg("Select image");
      return;
    }
    if (selectedType == 1 && video == null) {
      _showMsg("Select video");
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      /// upload media
      String mediaUrl = "";

      if (selectedType == 0) {
        mediaUrl = await uploadFile(image!, false);
      } else {
        mediaUrl = await uploadFile(video!, true);
      }

      /// get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data()!;

      /// save post
      await FirebaseFirestore.instance.collection('posts').add({
        "uid": user.uid,
        "username": userData['username'],
        "profileUrl": userData['profileUrl'],
        "mediaUrl": mediaUrl,
        "caption": captionController.text.trim(),
        "location": locationController.text.trim(),
        "type": selectedType == 0 ? "image" : "video",
        "likes": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showMsg("Post uploaded 🚀");
      Navigator.pop(context);
    } catch (e) {
      _showMsg("Error: $e");
    }

    setState(() => isUploading = false);
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Create"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TOGGLE
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(children: [_tab("Photos", 0), _tab("Video", 1)]),
            ),

            const SizedBox(height: 20),

            /// PREVIEW
            GestureDetector(
              onTap: selectedType == 0 ? pickImage : pickVideo,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _preview(),
              ),
            ),

            const SizedBox(height: 20),

            _input(captionController, "Caption", Icons.edit, maxLines: 3),
            const SizedBox(height: 15),
            _input(locationController, "Location", Icons.location_on),

            const SizedBox(height: 25),

            /// 🚀 UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5100),
                ),
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(selectedType == 0 ? "Share Post" : "Upload Reel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String text, int index) {
    final isSelected = selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF5100) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _preview() {
    if (selectedType == 0) {
      if (image == null) {
        return const Center(child: Text("Tap to add photo"));
      }
      return Image.file(image!, fit: BoxFit.cover);
    } else {
      if (videoController == null) {
        return const Center(child: Text("Tap to add video"));
      }
      return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: VideoPlayer(videoController!),
      );
    }
  }

  Widget _input(
    TextEditingController c,
    String h,
    IconData i, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: h,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(i, color: Colors.white70),
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
