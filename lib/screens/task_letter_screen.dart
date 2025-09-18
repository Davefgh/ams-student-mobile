import 'package:flutter/material.dart';

class TaskLetterScreen extends StatelessWidget {
  const TaskLetterScreen({super.key, required this.taskTitle, required this.taskBody});

  final String taskTitle;
  final String taskBody;

  static Route<void> routeFromPayload(String? payload) {
    final String title;
    final String body;
    if (payload != null && payload.contains('|')) {
      final parts = payload.split('|');
      title = parts[0];
      body = parts.sublist(1).join('|');
    } else {
      title = 'Task';
      body = payload ?? 'No details';
    }
    return MaterialPageRoute(builder: (_) => TaskLetterScreen(taskTitle: title, taskBody: body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Letter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(taskTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  taskBody,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


