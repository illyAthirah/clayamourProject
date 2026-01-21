import 'package:flutter/material.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'main_nav_page.dart';
import 'package:clayamour/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';

  // 🎨 ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
      });
      return;
    }

    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;

    String text;
    if (strength < 0.3) {
      text = 'Weak';
    } else if (strength < 0.6) {
      text = 'Fair';
    } else if (strength < 0.8) {
      text = 'Good';
    } else {
      text = 'Strong';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🌸 Logo with decorative background
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),

              // 🌸 Brand with decorative background
              Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primary.withOpacity(0.15),
                            primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ClayAmour",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Handcrafted clay bouquets,\nmade with love and meaning.",
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _authToggle(),
              const SizedBox(height: 24),

              _formCard(),

              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: const Text("Forgot password?"),
                  ),
                ),

              const SizedBox(height: 24),

              _primaryButton(),

              const SizedBox(height: 24),

              _divider(),

              const SizedBox(height: 20),

              _socialButton(
                icon: Icons.g_mobiledata,
                label: "Continue with Google",
                onPressed: _signInWithGoogle,
              ),

              if (!isLogin) ...[
                const SizedBox(height: 24),
                const Text(
                  "By creating an account, you agree to our\nTerms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🔁 Login / Register toggle
  Widget _authToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _toggleButton("Login", isLogin),
          _toggleButton("Register", !isLogin),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_loading) return;
          setState(() => isLogin = label == "Login");
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [primary, Color(0xFFC97C5D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // 🧾 Form card
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isLogin) _input("Full Name", controller: _nameCtrl),
          _input("Email", controller: _emailCtrl),
          _input(
            "Password",
            controller: _passwordCtrl,
            obscure: true,
            onChanged: !isLogin ? _checkPasswordStrength : null,
          ),
          if (!isLogin && _passwordCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _passwordStrengthIndicator(),
            const SizedBox(height: 8),
          ],
          if (!isLogin)
            _input("Confirm Password", controller: _confirmCtrl, obscure: true),
        ],
      ),
    );
  }

  Widget _input(
    String label, {
    required TextEditingController controller,
    bool obscure = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _passwordStrengthIndicator() {
    Color strengthColor;
    if (_passwordStrength < 0.3) {
      strengthColor = Colors.red;
    } else if (_passwordStrength < 0.6) {
      strengthColor = Colors.orange;
    } else if (_passwordStrength < 0.8) {
      strengthColor = Colors.yellow.shade700;
    } else {
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.grey.shade300,
                  color: strengthColor,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🚀 Primary CTA
  Widget _primaryButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, Color(0xFFC97C5D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _loading ? null : _submit,
        child: Text(
          _loading ? "Please wait..." : (isLogin ? "Login" : "Create Account"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ➖ Divider
  Widget _divider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("or"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  // 🔐 Social button (UI)
  Widget _socialButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 15)),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onPressed: _loading ? null : onPressed ?? () {},
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim();
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      _showError("Please fill in all required fields.");
      return;
    }
    if (!isLogin && password != confirm) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _loading = true);
    try {
      if (isLogin) {
        await FirebaseService.signIn(email: email, password: password);
      } else {
        await FirebaseService.signUp(
          name: name,
          email: email,
          password: password,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavPage()),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError("Enter your email to reset password.");
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent.")),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final userCredential = await FirebaseService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavPage()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
