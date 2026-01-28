import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'storage_service.dart';

class ApiService {
  // Get base URL based on platform
  // Android Emulator: Use 10.0.2.2 (maps to host machine's localhost)
  // Physical Device: Use your computer's IP address on the local network
  // Web: Use localhost

  // Your computer's IP address on the local network (for physical devices)
  // Replace with your actual IP: Run 'ipconfig' on Windows
  static const String localNetworkIp =
      '192.168.254.106'; // Your IP from ipconfig

  // Backend server configuration
  // For development with physical devices, use HTTP to avoid SSL certificate issues
  // Change to true and port 8081 for HTTPS in production
  static const bool useHttps =
      false; // Use HTTP for development (avoids self-signed cert issues)
  static const int serverPort = 8080; // HTTP port (8081 for HTTPS)

import 'package:flutter_dotenv/flutter_dotenv.dart';

  static String get baseUrl {
    return dotenv.env['API_URL'] ?? 'http://localhost:8080';
  }

  final StorageService _storageService = StorageService();

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('Attempting login to: $baseUrl/api/account/login');
      print('Request body: ${json.encode(request.toJson())}');

      final url = Uri.parse('$baseUrl/api/account/login');

      // Create a client that doesn't follow redirects automatically
      // This allows us to handle 307 redirects manually
      final client = http.Client();

      try {
        final response = await client
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: json.encode(request.toJson()),
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Connection timeout');
              },
            );

        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        // Handle 307 redirect - backend redirecting HTTP to HTTPS
        if (response.statusCode == 307 ||
            response.statusCode == 301 ||
            response.statusCode == 302) {
          final location =
              response.headers['location'] ?? response.headers['Location'];
          if (location != null) {
            print('Redirect detected to: $location');
            // If redirected to HTTPS and we're using HTTP, try HTTP endpoint directly
            if (location.contains('https://') && !useHttps) {
              // Backend is redirecting HTTP to HTTPS - we need to use HTTPS or fix backend
              return LoginResponse(
                success: false,
                message:
                    'Backend requires HTTPS. Please configure backend to accept HTTP in development.',
              );
            }
          }
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return LoginResponse.fromJson(data);
        } else {
          return LoginResponse(
            success: false,
            message: 'Login failed. Status: ${response.statusCode}',
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('Login error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Helper method to get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Example method for authenticated GET requests
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    return response;
  }

  // Example method for authenticated POST requests
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    return response;
  }

  // ==================== STUDENT PROFILE METHODS ====================

  /// Get current user profile (student)
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse('$baseUrl/api/account/me');
      print('🌐 Fetching student profile from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Profile Response Status: ${response.statusCode}');
      print('📝 Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getStudentProfile: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  /// Update account profile using /api/account/profile endpoint
  /// Supports: firstname, lastname, email, password changes, sectionId, isRegular
  Future<Map<String, dynamic>> updateAccountProfile({
    String? firstname,
    String? lastname,
    String? email,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    int? sectionId,
    bool? isRegular,
  }) async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse('$baseUrl/api/account/profile');
      print('🌐 Updating account profile at: $url');

      // Build update data - only include non-null fields
      final Map<String, dynamic> updateData = {};
      if (firstname != null) updateData['firstname'] = firstname;
      if (lastname != null) updateData['lastname'] = lastname;
      if (email != null) updateData['email'] = email;
      if (currentPassword != null)
        updateData['currentPassword'] = currentPassword;
      if (newPassword != null) updateData['newPassword'] = newPassword;
      if (confirmNewPassword != null)
        updateData['confirmNewPassword'] = confirmNewPassword;
      if (sectionId != null) updateData['sectionId'] = sectionId;
      if (isRegular != null) updateData['isRegular'] = isRegular;

      print('📝 Update data: $updateData');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      print('📊 Update Response Status: ${response.statusCode}');
      print('📝 Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'data': data['updatedProfile'] ?? data,
        };
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Invalid data',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'You do not have permission to update your profile.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in updateAccountProfile: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ==================== STUDENT ENROLLMENT METHODS ====================

  /// Get student subjects
  Future<Map<String, dynamic>> getStudentSubjects() async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse('$baseUrl/api/students/my-subjects');
      print('🌐 Fetching subjects from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Subjects Response Status: ${response.statusCode}');
      print('📝 Subjects Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load subjects: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getStudentSubjects: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }
  // ==================== QR CODE METHODS ====================

  /// Scan QR Code
  Future<Map<String, dynamic>> scanQrCode({
    required String qrHash,
    required int studentId,
  }) async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse('$baseUrl/api/QrCode/scan');
      print('🌐 Scanning QR code at: $url');
      print('📝 Scan Data: qrHash=$qrHash, studentId=$studentId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'qrHash': qrHash, 'studentId': studentId}),
      );

      print('📊 Scan Response Status: ${response.statusCode}');
      print('📝 Scan Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // API returns 200 for success
        // The response body might be empty or contain success message
        // Based on user screenshot, it returns 200 Success
        return {
          'success': true,
          'message': 'Attendance recorded successfully!',
        };
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to record attendance';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {
          // If response is not JSON, use default error or status code
          errorMessage = 'Error: ${response.statusCode}';
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('💥 Error in scanQrCode: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Get Scan History by Student ID
  Future<Map<String, dynamic>> getScanHistoryByStudent({
    required int studentId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse(
        '$baseUrl/api/QrCode/$studentId/scan-history?pageNumber=$pageNumber&pageSize=$pageSize',
      );
      print('🌐 Fetching scan history from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Scan History Response Status: ${response.statusCode}');
      print('📝 Scan History Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Failed to load scan history: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getScanHistoryByStudent: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  /// Get Scan History by QR Hash
  Future<Map<String, dynamic>> getScanHistoryByHash({
    required String qrHash,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final token = await _storageService.getAccessToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = Uri.parse(
        '$baseUrl/api/QrCode/hash/$qrHash/scan-history?pageNumber=$pageNumber&pageSize=$pageSize',
      );
      print('🌐 Fetching scan history by hash from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Scan History Hash Response Status: ${response.statusCode}');
      print('📝 Scan History Hash Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Failed to load scan history: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getScanHistoryByHash: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }
}
