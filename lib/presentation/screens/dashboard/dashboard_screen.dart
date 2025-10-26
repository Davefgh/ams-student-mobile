import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data - Replace with API calls to your .NET backend
  final List<Map<String, dynamic>> studentSubjects = [
    {
      'subject': {'id': 1, 'name': 'Data Structures and Algorithms', 'code': 'CS201'},
      'schedule': {
        'timeIn': {'hour': 8, 'minute': 0},
        'timeOut': {'hour': 10, 'minute': 0},
        'dayOfWeek': 'Monday',
      },
      'instructor': {'firstname': 'John', 'lastname': 'Smith'},
      'classroom': {'name': 'Room 301'},
      'attendanceRate': 85,
    },
    {
      'subject': {'id': 2, 'name': 'Database Management Systems', 'code': 'CS202'},
      'schedule': {
        'timeIn': {'hour': 13, 'minute': 0},
        'timeOut': {'hour': 15, 'minute': 0},
        'dayOfWeek': 'Tuesday',
      },
      'instructor': {'firstname': 'Sarah', 'lastname': 'Johnson'},
      'classroom': {'name': 'Room 205'},
      'attendanceRate': 90,
    },
    {
      'subject': {'id': 3, 'name': 'Web Development', 'code': 'CS203'},
      'schedule': {
        'timeIn': {'hour': 10, 'minute': 30},
        'timeOut': {'hour': 12, 'minute': 30},
        'dayOfWeek': 'Wednesday',
      },
      'instructor': {'firstname': 'Michael', 'lastname': 'Brown'},
      'classroom': {'name': 'Lab 102'},
      'attendanceRate': 88,
    },
  ];

  String _formatTime(Map<String, dynamic> timeObj) {
    final hour = timeObj['hour'].toString().padLeft(2, '0');
    final minute = timeObj['minute'].toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 16),
                      _buildStatsCards(),
                      const SizedBox(height: 16),
                      _buildSubjectsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0x1AFFFFFF), // Changed from withOpacity(0.1)
        border: Border(bottom: BorderSide(color: Color(0x33FFFFFF))), // Changed from withOpacity(0.2)
      ),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attendance Monitoring',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Student Portal', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
              Positioned(
                right: 8, top: 8,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(width: 40, height: 40, child: CustomPaint(painter: _LogoPainter()));
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back, Student!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 4),
          Text('Here\'s your attendance overview', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Classes', '48', Icons.calendar_today, const Color(0xFF3B82F6), const Color(0xFFDCE9FF)),
        _buildStatCard('Attended', '42', Icons.check_circle, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
        _buildStatCard('Absent', '6', Icons.cancel, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
        _buildStatCard('Rate', '87.5%', Icons.person, const Color(0xFF3B82F6), const Color(0xFFDCE9FF)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500))),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              Text('${studentSubjects.length} subjects', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          ...studentSubjects.map((item) => _buildSubjectCard(item)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> item) {
    final subject = item['subject'];
    final schedule = item['schedule'];
    final instructor = item['instructor'];
    final classroom = item['classroom'];
    final rate = item['attendanceRate'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEFF6FF), Colors.white]),
        border: Border.all(color: const Color(0xFFDCE9FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                child: Text(subject['code'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(subject['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)))),
              const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, 'Instructor', '${instructor['firstname']} ${instructor['lastname']}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'Schedule', '${schedule['dayOfWeek']} ${_formatTime(schedule['timeIn'])} - ${_formatTime(schedule['timeOut'])}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Classroom', classroom['name']),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attendance Progress', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('$rate%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: rate / 100, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)), minHeight: 6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)))),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final redPaint = Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.fill;

    // White triangle
    final trianglePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height * 0.6)
      ..close();
    canvas.drawPath(trianglePath, whitePaint);

    // Red diamond 1
    final diamond1 = Path()
      ..moveTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();
    canvas.drawPath(diamond1, redPaint);

    // Red diamond 2
    final diamond2 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..close();
    canvas.drawPath(diamond2, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}