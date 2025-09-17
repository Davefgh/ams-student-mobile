import 'package:flutter/material.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  static const String _demoUsername = 'stud123';
  static const String _demoPassword = 'stud123';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter student ID or email';
    // Basic email pattern; if not email, treat as ID (non-empty already checked)
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (trimmed.contains('@') && !emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter your password';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final enteredId = _identifierController.text.trim();
    final enteredPw = _passwordController.text;
    final isValid = enteredId == _demoUsername && enteredPw == _demoPassword;
    setState(() => _isSubmitting = false);

    if (isValid) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.school, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Student Login',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _identifierController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Student ID or Email',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: _validateIdentifier,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: _validatePassword,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                )
                              : const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


