import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  final _apiService = ApiService();
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.getStudentProfile();
      
      if (mounted) {
        if (response['success'] == true && response['data'] != null) {
          setState(() {
            _profileData = response['data'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          _showError(response['error'] ?? 'Failed to load profile');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error loading profile: $e');
      }
    }
  }

  void _showEditEmailModal() async {
    if (_profileData == null) return;
    
    final studentProfile = _profileData?['studentProfile'];
    final result = await showDialog<Map<String, String?>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditProfileDialog(
        currentFirstname: studentProfile?['firstname'] ?? '',
        currentLastname: studentProfile?['lastname'] ?? '',
        currentEmail: _profileData?['email'] ?? '',
        onSave: _handleUpdateProfile,
      ),
    );
    
    // After edit dialog closes, if we have result, handle the update
    if (result != null && mounted) {
      await _handleUpdateProfile(
        firstname: result['firstname'],
        lastname: result['lastname'],
        email: result['email'],
      );
    }
  }

  Future<void> _handleUpdateProfile({
    String? firstname,
    String? lastname,
    String? email,
  }) async {
    try {
      final response = await _apiService.updateAccountProfile(
        firstname: firstname,
        lastname: lastname,
        email: email,
      );

      if (response['success'] == true) {
        // Reload profile to get updated data
        await _loadProfile();
        
        // Add a small delay to ensure state is updated
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          // Show success modal
          _showProfileUpdatedModal();
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update profile: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  void _showProfileUpdatedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProfileUpdatedDialog(
        profileData: _profileData,
      ),
    );
  }

  String _getInitials() {
    final firstname = _profileData?['studentProfile']?['firstname'] ?? '';
    final lastname = _profileData?['studentProfile']?['lastname'] ?? '';
    
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      return '${firstname[0]}${lastname[0]}'.toUpperCase();
    } else if (firstname.isNotEmpty) {
      return firstname.substring(0, firstname.length > 1 ? 2 : 1).toUpperCase();
    }
    
    // Fallback to username
    final username = _profileData?['username'] ?? '';
    if (username.isEmpty) return 'N';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  String _getDisplayName() {
    final firstname = _profileData?['studentProfile']?['firstname'] ?? '';
    final lastname = _profileData?['studentProfile']?['lastname'] ?? '';
    
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      return '$firstname $lastname';
    } else if (firstname.isNotEmpty) {
      return firstname;
    } else if (lastname.isNotEmpty) {
      return lastname;
    }
    
    // Fallback to username
    return _profileData?['username'] ?? 'No Name';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _LogoutDialog(),
    );

    if (confirmed == true) {
      await _authRepository.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E40AF),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Logo without white background
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/ACLCv1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _handleLogout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _profileData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load profile',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadProfile,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Profile Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1E40AF),
                                      Color(0xFF3B82F6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Edit Email button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: _showEditEmailModal,
                                          tooltip: 'Edit Profile',
                                        ),
                                      ],
                                    ),
                                    
                                    // Avatar
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getInitials(),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Display Name (firstname + lastname, or username as fallback)
                                    Text(
                                      _getDisplayName(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Email
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _profileData?['email'] ?? 'No email',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Student Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _profileData?['role'] ?? 'Student',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Information Section
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'INFORMATION',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // First Name
                              _InfoItem(
                                icon: Icons.person_outline,
                                label: 'First Name',
                                value: _profileData?['studentProfile']?['firstname'] ?? 'N/A',
                              ),
                              
                              // Last Name
                              _InfoItem(
                                icon: Icons.person_outline,
                                label: 'Last Name',
                                value: _profileData?['studentProfile']?['lastname'] ?? 'N/A',
                              ),
                              
                              // Username (read-only)
                              _InfoItem(
                                icon: Icons.person,
                                label: 'Username',
                                value: _profileData?['username'] ?? 'N/A',
                              ),
                              
                              // Email
                              _InfoItem(
                                icon: Icons.email,
                                label: 'Email',
                                value: _profileData?['email'] ?? 'N/A',
                              ),
                              
                              // Student ID
                              _InfoItem(
                                icon: Icons.badge,
                                label: 'Student ID',
                                value: '#${_profileData?['studentProfile']?['id'] ?? 'N/A'}',
                              ),
                              
                              // Section
                              _InfoItem(
                                icon: Icons.class_,
                                label: 'Section',
                                value: _profileData?['studentProfile']?['sectionName'] ?? 'N/A',
                              ),
                              
                              // Course
                              _InfoItem(
                                icon: Icons.school,
                                label: 'Course',
                                value: _profileData?['studentProfile']?['courseName'] ?? 'N/A',
                              ),
                              
                              // Regular Status
                              _InfoItem(
                                icon: Icons.verified_user,
                                label: 'Status',
                                value: (_profileData?['studentProfile']?['isRegular'] == true) 
                                    ? 'Regular' 
                                    : 'Irregular',
                              ),
                              
                              // Member Since
                              _InfoItem(
                                icon: Icons.calendar_today,
                                label: 'Member Since',
                                value: _formatDate(_profileData?['createdAt']),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// Info Item Widget
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Dialog (Firstname, Lastname, Email)
class _EditProfileDialog extends StatefulWidget {
  final String currentFirstname;
  final String currentLastname;
  final String currentEmail;
  final Function({String? firstname, String? lastname, String? email})? onSave;

  const _EditProfileDialog({
    required this.currentFirstname,
    required this.currentLastname,
    required this.currentEmail,
    required this.onSave,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.currentFirstname);
    _lastnameController = TextEditingController(text: widget.currentLastname);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final email = _emailController.text.trim();

    // Check if anything actually changed
    if (firstname == widget.currentFirstname &&
        lastname == widget.currentLastname &&
        email == widget.currentEmail) {
      Navigator.of(context).pop();
      return;
    }

    // Return the values to parent, then parent will handle update and show success modal
    Navigator.of(context).pop({
      'firstname': firstname.isNotEmpty ? firstname : null,
      'lastname': lastname.isNotEmpty ? lastname : null,
      'email': email.isNotEmpty ? email : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ACLC Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/ACLCv1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF3B82F6),
                          size: 40,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Update your profile information',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 28),

                // First Name Field
                TextFormField(
                  controller: _firstnameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    // First name is optional, but if provided should be valid
                    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                      return 'First name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),

                // Last Name Field
                TextFormField(
                  controller: _lastnameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    // Last name is optional, but if provided should be valid
                    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                      return 'Last name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 28),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Profile Updated Success Dialog
class _ProfileUpdatedDialog extends StatelessWidget {
  final Map<String, dynamic>? profileData;

  const _ProfileUpdatedDialog({
    this.profileData,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getUpdatedValue(String field) {
    if (profileData == null) return 'N/A';
    
    switch (field) {
      case 'firstname':
        return profileData?['studentProfile']?['firstname'] ?? 'N/A';
      case 'lastname':
        return profileData?['studentProfile']?['lastname'] ?? 'N/A';
      case 'email':
        return profileData?['email'] ?? 'N/A';
      case 'createdAt':
        return _formatDate(profileData?['createdAt']);
      case 'updatedAt':
        // Use updatedAt from profile, or current time if not available
        return _formatDate(profileData?['updatedAt'] ?? DateTime.now().toIso8601String());
      default:
        return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ACLC Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/ACLCv1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Profile Updated!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            const Text(
              'Your profile has been successfully updated',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Profile Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name
                  _DetailRow(
                    label: 'First Name',
                    value: _getUpdatedValue('firstname'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Last Name
                  _DetailRow(
                    label: 'Last Name',
                    value: _getUpdatedValue('lastname'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email
                  _DetailRow(
                    label: 'Email',
                    value: _getUpdatedValue('email'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Created At
                  _DetailRow(
                    label: 'Created At',
                    value: _getUpdatedValue('createdAt'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Updated At
                  _DetailRow(
                    label: 'Updated At',
                    value: _getUpdatedValue('updatedAt'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Done Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detail Row Widget for Profile Updated Dialog
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// Logout Confirmation Dialog
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ACLC Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/ACLCv1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Message
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
