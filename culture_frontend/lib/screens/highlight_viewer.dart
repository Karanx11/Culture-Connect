import 'package:flutter/material.dart';

class HighlightViewer extends StatefulWidget {
  final List<String> stories;

  const HighlightViewer({super.key, required this.stories});

  @override
  State<HighlightViewer> createState() => _HighlightViewerState();
}

class _HighlightViewerState extends State<HighlightViewer> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() async {
    while (index < widget.stories.length) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        index++;
      });

      if (index >= widget.stories.length) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Image.network(
        widget.stories[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
