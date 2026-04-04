import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _controller = PageController();
  final List<bool> liked = List.generate(10, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemBuilder: (context, index) {
          return _reelItem(index);
        },
      ),
    );
  }

  /// 🎥 SINGLE REEL
  Widget _reelItem(int index) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() => liked[index] = !liked[index]);
      },
      child: Stack(
        children: [
          /// 🎬 BACKGROUND (VIDEO / IMAGE PLACEHOLDER)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5100), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 📍 USER INFO (optional)
          Positioned(
            bottom: 80,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@user_$index",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Exploring culture 🌍",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// ❤️ LIKE + SHARE BUTTONS
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                /// LIKE
                IconButton(
                  icon: Icon(
                    liked[index] ? Icons.favorite : Icons.favorite_border,
                    color: liked[index] ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => liked[index] = !liked[index]);
                  },
                ),

                const SizedBox(height: 10),

                /// SHARE
                IconButton(
                  icon: const Icon(Icons.send, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Share clicked")),
                    );
                  },
                ),
              ],
            ),
          ),

          /// 🔝 TOP TEXT
          const Positioned(
            top: 50,
            left: 16,
            child: Text(
              "Explore",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
