import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "New follower",
      "subtitle": "Rahul started following you",
      "time": DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      "title": "Post liked",
      "subtitle": "Aman liked your post",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "title": "Comment",
      "subtitle": "Someone commented on your post",
      "time": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "title": "New follower",
      "subtitle": "Priya started following you",
      "time": DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  /// 🔥 GROUP BY MONTH & DATE
  Map<String, Map<String, List<Map<String, dynamic>>>> groupData() {
    Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var notif in notifications) {
      DateTime time = notif["time"];

      String month = DateFormat('MMMM yyyy').format(time);
      String date = DateFormat('dd MMM yyyy').format(time);

      grouped.putIfAbsent(month, () => {});
      grouped[month]!.putIfAbsent(date, () => []);
      grouped[month]![date]!.add(notif);
    }

    return grouped;
  }

  /// ❌ DELETE CONFIRMATION
  Future<bool> confirmDelete(int index) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Notification"),
            content: const Text("Are you sure you want to delete this?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupData();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        children: grouped.entries.map((monthEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 📅 MONTH
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  monthEntry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ...monthEntry.value.entries.map((dateEntry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🗓 DATE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        dateEntry.key,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),

                    /// 🔔 NOTIFICATIONS
                    ...dateEntry.value.map((notif) {
                      int index = notifications.indexOf(notif);

                      return Dismissible(
                        key: Key(index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await confirmDelete(index);
                        },
                        onDismissed: (_) {
                          setState(() {
                            notifications.removeAt(index);
                          });
                        },
                        child: ListTile(
                          leading: const CircleAvatar(),
                          title: Text(notif["title"]),
                          subtitle: Text(notif["subtitle"]),
                          trailing: Text(
                            DateFormat('hh:mm a').format(notif["time"]),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
