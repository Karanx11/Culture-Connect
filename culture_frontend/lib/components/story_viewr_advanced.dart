import 'package:flutter/material.dart';

class StoryViewerAdvanced extends StatefulWidget {
  final List stories;

  const StoryViewerAdvanced({super.key, required this.stories});

  @override
  State<StoryViewerAdvanced> createState() => _StoryViewerAdvancedState();
}

class _StoryViewerAdvancedState extends State<StoryViewerAdvanced> {
  int currentIndex = 0;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() async {
    while (currentIndex < widget.stories.length) {
      progress = 0;

      for (int i = 0; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 30));

        if (!mounted) return;

        setState(() {
          progress = i / 100;
        });
      }

      currentIndex++;

      if (currentIndex >= widget.stories.length) {
        Navigator.pop(context);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(story['imageUrl'], fit: BoxFit.cover),
          ),

          /// PROGRESS
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: LinearProgressIndicator(
              value: progress,
              color: Colors.white,
              backgroundColor: Colors.white30,
            ),
          ),

          /// USER
          Positioned(
            top: 70,
            left: 10,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(story['profileUrl']),
                ),
                const SizedBox(width: 10),
                Text(
                  story['username'],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          /// CAPTION
          if ((story['caption'] ?? "").isNotEmpty)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Text(
                story['caption'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
