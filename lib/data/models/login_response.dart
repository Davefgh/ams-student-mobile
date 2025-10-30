class LoginResponse {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final String? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user,
    };
  }
}


