import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/services/firebase_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  bool _passwordsMatch = false;
  int _passwordStrength = 0; // 0 = weak, 1 = medium, 2 = strong

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _passwordField("Current Password", _currentCtrl),
            _passwordField("New Password", _newCtrl, onChanged: _checkPassword),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [_strengthBar(0), _strengthBar(1), _strengthBar(2)],
                ),
                const SizedBox(height: 6),
                Text(
                  _passwordStrength == 0
                      ? "Weak password"
                      : _passwordStrength == 1
                      ? "Medium strength"
                      : "Strong password",
                  style: TextStyle(
                    fontSize: 12,
                    color: _passwordStrength == 0
                        ? Colors.red
                        : _passwordStrength == 1
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            _passwordField(
              "Confirm New Password",
              _confirmCtrl,
              onChanged: (v) {
                setState(() {
                  _passwordsMatch = v == _newCtrl.text;
                });
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        color: background,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: (_saving || !_passwordsMatch || _passwordStrength == 0)
                ? null
                : _changePassword,
            child: Text(
              _saving ? "Updating..." : "Update Password",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: true,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: surface,
              suffixIcon: const Icon(Icons.visibility_off),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strengthBar(int level) {
    Color activeColor;

    if (_passwordStrength == 0) {
      activeColor = Colors.red;
    } else if (_passwordStrength == 1) {
      activeColor = Colors.orange;
    } else {
      activeColor = Colors.green;
    }

    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: _passwordStrength >= level + 1
              ? activeColor
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseService.currentUser;
    if (user == null || user.email == null) return;
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    if (newPass != confirm) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _saving = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password updated.")));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _showError("Current password is incorrect.");
          break;
        case 'weak-password':
          _showError("Password is too weak.");
          break;
        case 'requires-recent-login':
          _showError("Please log in again and try.");
          break;
        default:
          _showError("Failed to update password.");
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _checkPassword(String value) {
    int strength = 0;

    if (value.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value))
      strength++;

    setState(() {
      _passwordStrength = strength;
      _passwordsMatch = value == _confirmCtrl.text;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
