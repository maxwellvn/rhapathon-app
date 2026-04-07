import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passController = TextEditingController();
  bool _loading  = false;
  bool _obscure  = true;
  String? _error;

  Future<void> _login() async {
    final input = _passController.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Please enter the access password');
      return;
    }

    if (AppConfig.accessPassword.isEmpty) {
      setState(() => _error = 'Sign-in unavailable.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    await Future.delayed(const Duration(milliseconds: 300)); // brief visual feedback

    if (input != AppConfig.accessPassword) {
      setState(() { _error = 'Incorrect password'; _loading = false; });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    widget.onLogin();
  }

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/rhap_logo.png', height: 90),
                const SizedBox(height: 24),
                const Text(
                  'Rhapathon 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attendee Search',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
                ),
                const SizedBox(height: 48),

                // Password field
                TextField(
                  controller: _passController,
                  obscureText: _obscure,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: 'Enter access password',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      disabledBackgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
