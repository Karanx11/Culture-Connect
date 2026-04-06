import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryViewerScreen extends StatefulWidget {
  final QueryDocumentSnapshot story;

  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      setState(() {
        progress = i / 100;
      });
    }

    Navigator.pop(context); // auto close
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.story.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// STORY IMAGE
          Positioned.fill(
            child: Image.network(data['imageUrl'], fit: BoxFit.cover),
          ),

          /// PROGRESS BAR
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),

          /// USER INFO
          Positioned(
            top: 60,
            left: 10,
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(data['profileUrl'])),
                const SizedBox(width: 10),
                Text(
                  data['username'],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          /// CAPTION
          if ((data['caption'] ?? "").isNotEmpty)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Text(
                data['caption'],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
