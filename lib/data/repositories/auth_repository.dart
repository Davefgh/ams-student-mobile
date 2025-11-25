import '../models/login_request.dart';
import '../models/login_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await _apiService.login(request);

    // Check if login was successful
    if (response.success) {
      // Validate role - only allow Student
      if (response.role != 'Student') {
        // Return generic error message for security
        return LoginResponse(
          success: false,
          message: 'Invalid username or password',
        );
      }

      if (response.accessToken != null) {
        // Save tokens to local storage
        await _storageService.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? '',
          username: response.user ?? username,
        );
      }
    }

    return response;
  }

  Future<void> logout() async {
    await _storageService.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<String?> getUsername() async {
    return await _storageService.getUsername();
  }
}
