import 'package:flutter/material.dart';
import 'main_nav_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

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
                    onPressed: () {},
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
              ),
              const SizedBox(height: 12),
              _socialButton(
                icon: Icons.apple,
                label: "Continue with Apple",
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
        onTap: () => setState(() => isLogin = label == "Login"),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isLogin) _input("Full Name"),
          _input("Email"),
          _input("Password", obscure: true),
          if (!isLogin) _input("Confirm Password", obscure: true),
        ],
      ),
    );
  }

  Widget _input(String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
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
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavPage()),
          );
        },
        child: Text(
          isLogin ? "Login" : "Create Account",
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
  Widget _socialButton({required IconData icon, required String label}) {
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
        onPressed: () {},
      ),
    );
  }
}
