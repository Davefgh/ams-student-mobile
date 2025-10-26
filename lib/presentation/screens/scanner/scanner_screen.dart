import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  
  bool _isProcessing = false;
  bool _hasScanned = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // This makes it loop infinitely
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCodeScanned(String qrData) async {
    if (_isProcessing || _hasScanned) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    try {
      // Parse QR code data
      final Map<String, dynamic> qrCodeData = jsonDecode(qrData);
      
      print('📱 QR Code Scanned: $qrCodeData');
      
      // Extract data from QR code
      final int scheduleId = qrCodeData['scheduleId'];
      final int sectionId = qrCodeData['sectionId'];
      final int actualRoomId = qrCodeData['actualRoomId'];
      final String uniqueHash = qrCodeData['uniqueHash'];
      
      // Show processing dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Recording attendance...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Submit attendance to backend
      final result = await _submitAttendance(
        scheduleId: scheduleId,
        sectionId: sectionId,
        actualRoomId: actualRoomId,
        uniqueHash: uniqueHash,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog
        
        if (result['success']) {
          _showSuccessDialog(result['message'] ?? 'Attendance recorded successfully!');
        } else {
          _showErrorDialog(result['message'] ?? 'Failed to record attendance');
        }
      }
    } catch (e) {
      print('❌ Error processing QR code: $e');
      
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog if open
        _showErrorDialog('Invalid QR code format');
      }
    } finally {
      // Reset after 3 seconds to allow another scan
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _hasScanned = false;
          });
        }
      });
    }
  }

  Future<Map<String, dynamic>> _submitAttendance({
    required int scheduleId,
    required int sectionId,
    required int actualRoomId,
    required String uniqueHash,
  }) async {
    try {
      // TODO: Replace with your actual API call
      // Example:
      // final response = await http.post(
      //   Uri.parse('https://localhost:8081/api/Attendance/scan'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'scheduleId': scheduleId,
      //     'sectionId': sectionId,
      //     'actualRoomId': actualRoomId,
      //     'uniqueHash': uniqueHash,
      //   }),
      // );
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      print('📤 Submitting attendance:');
      print('   Schedule ID: $scheduleId');
      print('   Section ID: $sectionId');
      print('   Room ID: $actualRoomId');
      print('   Hash: $uniqueHash');
      
      // Mock success response
      return {
        'success': true,
        'message': 'Attendance recorded successfully!',
      };
      
      // Handle actual API response:
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return {
      //     'success': true,
      //     'message': data['message'] ?? 'Attendance recorded successfully!',
      //   };
      // } else {
      //   final data = jsonDecode(response.body);
      //   return {
      //     'success': false,
      //     'message': data['message'] ?? 'Failed to record attendance',
      //   };
      // }
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFEF4444),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleQRCodeScanned(code);
                }
              }
            },
          ),
          
          // Overlay with scanning frame
          _buildScannerOverlay(),
          
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      cameraController.torchEnabled
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => cameraController.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom instruction
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Corner decorations
              _buildCorner(Alignment.topLeft, true, true),
              _buildCorner(Alignment.topRight, true, false),
              _buildCorner(Alignment.bottomLeft, false, true),
              _buildCorner(Alignment.bottomRight, false, false),
              
              // Scanning line animation (continuous loop)
              if (!_hasScanned)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * 260 + 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF3B82F6).withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, bool isTop, bool isLeft) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF3B82F6), width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF3B82F6), width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF3B82F6), width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF3B82F6), width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}