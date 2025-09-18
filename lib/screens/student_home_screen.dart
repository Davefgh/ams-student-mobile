import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  bool _isCheckedIn = false;
  final List<Map<String, String>> _notifications = <Map<String, String>>[];

  Future<void> _sendAttendanceNotification({required bool isIn}) async {
    final String timestamp = DateTime.now().toLocal().toString();
    final String title = isIn ? 'Attendance marked' : 'Checked out';
    final String body = isIn
        ? 'You attended class at ' + timestamp
        : 'You checked out at ' + timestamp;
    await NotificationService.instance.showSpillOverTaskNotification(
      title: title,
      body: body,
      payload: (isIn ? 'Attendance' : 'Checkout') + '|' + body,
    );
    setState(() {
      _notifications.insert(0, {'title': title, 'body': body});
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _ScannerPage(),
      _AttendPage(
        isCheckedIn: _isCheckedIn,
        onIn: () async {
          await _sendAttendanceNotification(isIn: true);
          if (mounted) {
            setState(() => _isCheckedIn = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Marked as In and notification sent')),
            );
          }
        },
        onOut: () async {
          await _sendAttendanceNotification(isIn: false);
          if (mounted) {
            setState(() => _isCheckedIn = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checked out and notification sent')),
            );
          }
        },
      ),
      _NotificationsPage(notifications: _notifications),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Attend'),
          NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Notifications'),
        ],
      ),
    );
  }
}

class _ScannerPage extends StatelessWidget {
  const _ScannerPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(Icons.qr_code_scanner, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Scanner', textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Text('Camera preview placeholder', style: theme.textTheme.bodyMedium),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scan action not implemented yet')),
              );
            },
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Start Scan'),
          ),
        ],
      ),
    );
  }
}

class _AttendPage extends StatelessWidget {
  const _AttendPage({required this.isCheckedIn, required this.onIn, required this.onOut});

  final bool isCheckedIn;
  final VoidCallback onIn;
  final VoidCallback onOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Icon(Icons.check_circle_outline, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Attend', textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mark your attendance', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Current time: ${now.toLocal()}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('In'),
                          onPressed: isCheckedIn ? null : onIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Out'),
                          onPressed: isCheckedIn ? onOut : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({required this.notifications});

  final List<Map<String, String>> notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: const Text('Notifications'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: notifications.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No notifications yet', style: theme.textTheme.bodyMedium),
                    ),
                  ),
                )
              : SliverList.builder(
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.notifications, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['body'] ?? ''),
                        onTap: () {},
                      ),
                    );
                  },
                  itemCount: notifications.length,
                ),
        ),
      ],
    );
  }
}


