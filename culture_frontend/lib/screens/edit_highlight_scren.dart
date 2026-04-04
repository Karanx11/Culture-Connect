import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditHighlightScreen extends StatefulWidget {
  final String id;
  final Map data;

  const EditHighlightScreen({super.key, required this.id, required this.data});

  @override
  State<EditHighlightScreen> createState() => _EditHighlightScreenState();
}

class _EditHighlightScreenState extends State<EditHighlightScreen> {
  late TextEditingController titleController;
  late List stories;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.data['title']);
    stories = List.from(widget.data['storyUrls']);
  }

  Future<void> updateHighlight() async {
    await FirebaseFirestore.instance
        .collection('highlights')
        .doc(widget.id)
        .update({"title": titleController.text, "storyUrls": stories});

    Navigator.pop(context);
  }

  Future<void> deleteHighlight() async {
    await FirebaseFirestore.instance
        .collection('highlights')
        .doc(widget.id)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Highlight"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteHighlight,
          ),
        ],
      ),

      body: Column(
        children: [
          TextField(controller: titleController),

          Expanded(
            child: GridView.builder(
              itemCount: stories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (_, i) {
                return Stack(
                  children: [
                    Image.network(stories[i], fit: BoxFit.cover),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => stories.removeAt(i));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          ElevatedButton(onPressed: updateHighlight, child: const Text("Save")),
        ],
      ),
    );
  }
}
