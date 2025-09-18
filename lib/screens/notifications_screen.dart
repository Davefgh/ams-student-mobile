import 'package:flutter/material.dart';
import 'task_letter_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tasks = [
      {'title': 'Spill-over: Math Homework', 'body': 'Complete chapter 5 exercises.'},
      {'title': 'Spill-over: Lab Report', 'body': 'Submit the physics lab report.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = tasks[index];
          return ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(item['title'] ?? ''),
            subtitle: Text(item['body'] ?? ''),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskLetterScreen(
                    taskTitle: item['title'] ?? 'Task',
                    taskBody: item['body'] ?? 'No details',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


