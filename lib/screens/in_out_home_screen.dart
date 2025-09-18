import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'notifications_screen.dart';

class InOutHomeScreen extends StatefulWidget {
  const InOutHomeScreen({super.key});

  @override
  State<InOutHomeScreen> createState() => _InOutHomeScreenState();
}

class _InOutHomeScreenState extends State<InOutHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _InPage(),
      _OutPage(),
      const _QrPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('AMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          )
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.login), label: 'In'),
          NavigationDestination(icon: Icon(Icons.logout), label: 'Out'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'QR'),
        ],
      ),
    );
  }
}

class _InPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Check In'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked In')));
            },
            child: const Text('Tap to Check In'),
          ),
        ],
      ),
    );
  }
}

class _OutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Check Out'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked Out')));
            },
            child: const Text('Tap to Check Out'),
          ),
        ],
      ),
    );
  }
}

class _QrPage extends StatelessWidget {
  const _QrPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Scan QR to mark attendance'),
        ),
        Expanded(
          child: MobileScanner(
            controller: MobileScannerController(formats: const [BarcodeFormat.qrCode]),
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final value = barcodes.first.rawValue;
                if (value != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR: $value')));
                }
              }
            },
          ),
        )
      ],
    );
  }
}


