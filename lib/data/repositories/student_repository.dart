import '../services/api_service.dart';

class StudentRepository {
  final ApiService _apiService = ApiService();

  /// Get student profile from /api/account/me
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _apiService.getStudentProfile();
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to load profile: $e',
      };
    }
  }

  /// Update student profile
  Future<Map<String, dynamic>> updateProfile({
    required int studentId,
    required String email,
  }) async {
    try {
      return await _apiService.updateStudentProfile(
        studentId: studentId,
        email: email,
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update profile: $e',
      };
    }
  }
}

