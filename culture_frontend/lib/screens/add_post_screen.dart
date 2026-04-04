import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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

  int selectedType = 0; // 0 = Post, 1 = Reel

  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

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
            /// 🔥 TOGGLE (POST / REEL)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [_tabButton("Photos", 0), _tabButton("Video", 1)],
              ),
            ),

            const SizedBox(height: 20),

            /// 📸 / 🎥 PREVIEW
            GestureDetector(
              onTap: selectedType == 0 ? pickImage : pickVideo,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: _buildPreview(),
              ),
            ),

            const SizedBox(height: 20),

            /// 🧊 CAPTION
            _glassInput(
              controller: captionController,
              hint: "Write a caption...",
              icon: Icons.edit,
              maxLines: 3,
            ),

            const SizedBox(height: 15),

            /// 📍 LOCATION
            _glassInput(
              controller: locationController,
              hint: "Add location",
              icon: Icons.location_on,
            ),

            const SizedBox(height: 25),

            /// 🚀 SHARE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (selectedType == 0 && image == null) {
                    _showMsg("Please select an image");
                    return;
                  }
                  if (selectedType == 1 && video == null) {
                    _showMsg("Please select a video");
                    return;
                  }

                  _showMsg("Uploaded successfully 🚀");
                  Navigator.pop(context);
                },
                child: Text(
                  selectedType == 0 ? "Share Post" : "Upload Reel",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 TAB BUTTON
  Widget _tabButton(String text, int index) {
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

  /// 🎥 / 📸 PREVIEW BUILDER
  Widget _buildPreview() {
    if (selectedType == 0) {
      /// IMAGE
      if (image == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.white70),
              SizedBox(height: 10),
              Text("Tap to add photo", style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(image!, fit: BoxFit.cover),
        );
      }
    } else {
      /// VIDEO
      if (video == null || videoController == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_call, size: 40, color: Colors.white70),
              SizedBox(height: 10),
              Text("Tap to add reel", style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: videoController!.value.aspectRatio,
            child: VideoPlayer(videoController!),
          ),
        );
      }
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 🧊 INPUT
  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
