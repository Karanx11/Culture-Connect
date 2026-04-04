import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? image;
  final picker = ImagePicker();

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
    pickImage(); // auto open gallery
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
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Story added 🚀")));
              Navigator.pop(context);
            },
            child: const Text(
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
                /// 🖼 FULL SCREEN IMAGE
                Positioned.fill(child: Image.file(image!, fit: BoxFit.cover)),

                /// ✏️ TEXT INPUT
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: TextField(
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

                /// 📸 CHANGE IMAGE
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
