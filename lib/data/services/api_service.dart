import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'storage_service.dart';

class ApiService {
  // Update this to match your backend URL
  static const String baseUrl = 'https://localhost:8081';
  
  final StorageService _storageService = StorageService();

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('Attempting login to: $baseUrl/api/account/login');
      print('Request body: ${json.encode(request.toJson())}');
      
      final url = Uri.parse('$baseUrl/api/account/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        return LoginResponse(
          success: false,
          message: 'Login failed. Status: ${response.statusCode}',
        );
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
        return {
          'success': true,
          'data': data,
        };
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
      return {
        'success': false,
        'error': 'Error: $e',
      };
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
      if (currentPassword != null) updateData['currentPassword'] = currentPassword;
      if (newPassword != null) updateData['newPassword'] = newPassword;
      if (confirmNewPassword != null) updateData['confirmNewPassword'] = confirmNewPassword;
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
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

}

