import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/attendance/scan_qr_screen.dart';
import '../features/attendance/attendance_list_screen.dart';
import '../features/classroom/subject_list_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/home/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String attendance = '/attendance';
  static const String subjects = '/subjects';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    scan: (context) => const ScanQrScreen(),
    attendance: (context) => const AttendanceListScreen(),
    subjects: (context) => const SubjectListScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
