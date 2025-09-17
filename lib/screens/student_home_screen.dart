import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  void _showStub(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title is not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Monitoring',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _DashboardCard(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      onTap: () => _showStub(context, 'Scan QR'),
                    ),
                    _DashboardCard(
                      icon: Icons.login,
                      label: 'Clock In',
                      onTap: () => _showStub(context, 'Clock In'),
                    ),
                    _DashboardCard(
                      icon: Icons.logout,
                      label: 'Clock Out',
                      onTap: () => _showStub(context, 'Clock Out'),
                    ),
                    _DashboardCard(
                      icon: Icons.priority_high_outlined,
                      label: 'Priority Tracking',
                      onTap: () => _showStub(context, 'Priority Tracking'),
                    ),
                    _DashboardCard(
                      icon: Icons.file_upload_outlined,
                      label: 'Import Attendance',
                      onTap: () => _showStub(context, 'Import Attendance'),
                    ),
                    _DashboardCard(
                      icon: Icons.file_download_outlined,
                      label: 'Export Attendance',
                      onTap: () => _showStub(context, 'Export Attendance'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}


