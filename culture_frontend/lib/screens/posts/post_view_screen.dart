import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostViewScreen extends StatelessWidget {
  final Map data;

  const PostViewScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(backgroundColor: Colors.transparent),

      body: Column(
        children: [
          /// MEDIA
          Expanded(
            child: data['type'] == "video"
                ? _video(data['mediaUrl'])
                : Image.network(
                    data['mediaUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),

          /// INFO
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${data['username']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(data['caption'] ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _video(String url) {
    final controller = VideoPlayerController.network(url);

    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        controller.play();

        return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        );
      },
    );
  }
}
