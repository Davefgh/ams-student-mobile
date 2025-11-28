import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../routes/app_router.dart';
import '../../../data/services/api_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController cameraController;
  final ApiService _apiService = ApiService();

  bool _isProcessing = false;
  bool _hasScanned = false;
  int? _studentId;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchStudentId();

    // Initialize camera with better settings for clarity
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // This makes it loop infinitely

    // Prevent screenshots and screen recording (no visible banner)
    _enableScreenshotPrevention();

    // Start camera and ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cameraController.start();
      }
    });
  }

  Future<void> _fetchStudentId() async {
    try {
      final profile = await _apiService.getStudentProfile();
      if (profile['success'] == true && mounted) {
        final data = profile['data'];
        // Handle various API response structures to find ID
        if (data['id'] != null) {
          _studentId = data['id'];
        } else if (data['studentProfile'] != null &&
            data['studentProfile']['id'] != null) {
          _studentId = data['studentProfile']['id'];
        } else if (data['user'] != null && data['user']['id'] != null) {
          _studentId = data['user']['id'];
        }
        print('✅ Fetched Student ID: $_studentId');
      }
    } catch (e) {
      print('❌ Error fetching student ID: $e');
    }
  }

  // Method channel for screenshot prevention
  static const MethodChannel _channel = MethodChannel('screenshot_prevention');

  // Enable screenshot prevention
  Future<void> _enableScreenshotPrevention() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (e) {
      print('Failed to enable screenshot prevention: $e');
    }
  }

  // Disable screenshot prevention
  Future<void> _disableScreenshotPrevention() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (e) {
      print('Failed to disable screenshot prevention: $e');
    }
  }

  @override
  void dispose() {
    // Re-enable screenshots when leaving scanner
    _disableScreenshotPrevention();
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCodeScanned(String qrData) async {
    final now = DateTime.now();

    // Debounce scans
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < _scanDebounce) {
      return;
    }

    if (_isProcessing || _hasScanned) return;

    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student ID not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
      _lastScanTime = now;
    });

    try {
      String uniqueHash;

      // 1. Try to parse as JSON first
      try {
        final Map<String, dynamic> qrCodeData = jsonDecode(qrData);
        if (qrCodeData.containsKey('uniqueHash')) {
          uniqueHash = qrCodeData['uniqueHash'];
          print('📱 QR Code (JSON): $qrCodeData');
        } else {
          // JSON valid but no uniqueHash? Treat whole JSON string as hash or fallback?
          // Let's assume if it's JSON but no uniqueHash, it might be the wrong QR,
          // BUT for flexibility, let's just use the raw data if we can't find the key.
          uniqueHash = qrData;
          print('⚠️ QR Code (JSON without uniqueHash): $qrData');
        }
      } catch (e) {
        // 2. If not JSON, assume the raw string IS the hash
        uniqueHash = qrData;
        print('📱 QR Code (Raw): $uniqueHash');
      }

      // 3. Show processing dialog
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

      // 4. Submit attendance
      final result = await _submitAttendance(
        uniqueHash: uniqueHash,
        studentId: _studentId!,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog

        if (result['success']) {
          _showSuccessDialog(
            result['message'] ?? 'Attendance recorded successfully!',
          );
        } else {
          _showErrorDialog(result['message'] ?? 'Failed to record attendance');
        }
      }
    } catch (e) {
      print('❌ Error processing QR code: $e');

      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('An error occurred: $e');
      }
    } finally {
      // Reset after delay
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
    required String uniqueHash,
    required int studentId,
  }) async {
    return await _apiService.scanQrCode(
      qrHash: uniqueHash,
      studentId: studentId,
    );
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

  // Debounce and Throttle variables
  DateTime? _lastScanTime;
  DateTime? _lastErrorTime;
  static const Duration _scanDebounce = Duration(seconds: 2);
  static const Duration _errorThrottle = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    // Calculate scan window centered on screen
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 280,
      height: 280,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view with improved clarity
          MobileScanner(
            controller: cameraController,
            scanWindow: scanWindow, // Restrict scanning to this window
            fit: BoxFit.cover,
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.dashboard,
                        (route) => false,
                      );
                    },
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
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
      // No dark overlay - let camera show clearly
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          // Remove white border - just show corner markers
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Stack(
            children: [
              // Corner decorations only - no white square
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          // Only show L-shaped corner indicators, no border
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
