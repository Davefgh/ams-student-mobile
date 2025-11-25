import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../scanner/scanner_screen.dart';
import '../profile/profile_screen.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/student_enrollment.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const ScannerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.qr_code_scanner_rounded, 'Scanner'),
                _buildNavItem(2, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<StudentSubject> _subjects = [];
  String? _error;
  String _studentName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch Profile
      final profileResponse = await _apiService.getStudentProfile();
      if (profileResponse['success'] == true) {
        final data = profileResponse['data'];
        setState(() {
          _studentName = data['firstname'] ?? 'Student';
        });
      }

      // Fetch Subjects
      final subjectsResponse = await _apiService.getStudentSubjects();
      if (subjectsResponse['success'] == true) {
        final List<dynamic> data = subjectsResponse['data'];
        setState(() {
          _subjects = data
              .map((json) => StudentSubject.fromJson(json))
              .toList();
        });
      } else {
        setState(() {
          _error = subjectsResponse['error'] ?? 'Failed to load subjects';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildQuickActionsGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('My Subjects'),
                      const SizedBox(height: 12),
                      _buildSubjectsList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Announcements'),
                      const SizedBox(height: 12),
                      _buildAnnouncements(),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Image.asset('assets/images/ACLCv1.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Student Portal',
                  style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateString,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hello, $_studentName!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          'Scan Attendance',
          Icons.qr_code_scanner_rounded,
          const Color(0xFF10B981),
          () {
            // Navigate to Scanner tab (index 1)
            final dashboardState = context
                .findAncestorStateOfType<_DashboardScreenState>();
            dashboardState?.setState(() {
              dashboardState._currentIndex = 1;
            });
          },
        ),
        _buildActionCard(
          'My Profile',
          Icons.person_rounded,
          const Color(0xFFF59E0B),
          () {
            // Navigate to Profile tab (index 2)
            final dashboardState = context
                .findAncestorStateOfType<_DashboardScreenState>();
            dashboardState?.setState(() {
              dashboardState._currentIndex = 2;
            });
          },
        ),
        _buildActionCard(
          'Class Schedule',
          Icons.calendar_today_rounded,
          const Color(0xFF8B5CF6),
          () {}, // Placeholder
        ),
        _buildActionCard(
          'History',
          Icons.history_rounded,
          const Color(0xFFEC4899),
          () {}, // Placeholder
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubjectsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.white));
    }
    if (_subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Text(
          'No subjects enrolled yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(_subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(StudentSubject studentSubject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  studentSubject.subject.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                studentSubject.schedule.dayOfWeek,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            studentSubject.subject.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildSubjectInfoRow(
            Icons.access_time_rounded,
            'Time',
            '${studentSubject.schedule.timeIn} - ${studentSubject.schedule.timeOut}',
          ),
          const SizedBox(height: 12),
          _buildSubjectInfoRow(
            Icons.person_rounded,
            'Instructor',
            studentSubject.instructor.fullName,
          ),
          const SizedBox(height: 12),
          _buildSubjectInfoRow(
            Icons.meeting_room_rounded,
            'Room',
            studentSubject.classroom.name,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAnnouncementCard(
            'Midterm Exams',
            'Schedule for midterm exams has been released.',
            const Color(0xFFEF4444),
          ),
          const SizedBox(width: 16),
          _buildAnnouncementCard(
            'Holiday Notice',
            'No classes on Friday due to National Holiday.',
            const Color(0xFF10B981),
          ),
          const SizedBox(width: 16),
          _buildAnnouncementCard(
            'System Maintenance',
            'Server maintenance scheduled for Sunday 2AM.',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String description, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Notice',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
