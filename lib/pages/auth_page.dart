import 'package:flutter/material.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'main_nav_page.dart';

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

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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
              const SizedBox(height: 40),

              // 🌸 Brand
              const Text(
                "ClayAmour",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Handcrafted clay bouquets,\nmade with love and meaning.",
                style: TextStyle(fontSize: 15, color: textSecondary),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
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
            color: active ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : textPrimary,
              fontWeight: FontWeight.w600,
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
          _input("Password", controller: _passwordCtrl, obscure: true),
          if (!isLogin)
            _input("Confirm Password",
                controller: _confirmCtrl, obscure: true),
        ],
      ),
    );
  }

  Widget _input(
    String label, {
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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

  // 🚀 Primary CTA
  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _loading ? null : _submit,
        child: Text(
          _loading ? "Please wait..." : (isLogin ? "Login" : "Create Account"),
          style: const TextStyle(fontSize: 16),
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
      height: 48,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

