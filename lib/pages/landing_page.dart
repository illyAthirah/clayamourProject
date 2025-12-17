import 'package:flutter/material.dart';
import 'package:clayamour/pages/auth_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // 🏷 Brand header
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                "ClayAmour",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: textPrimary,
                ),
              ),
            ),

            // 🌸 Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: const [
                  _OnboardPage(
                    title: "Handcrafted bouquets,\nmade just for them",
                    subtitle:
                        "Thoughtfully designed clay bouquets created with care and meaning.",
                    icon: Icons.local_florist,
                  ),
                  _OnboardPage(
                    title: "Because meaningful\ngifts take time",
                    subtitle:
                        "Every bouquet is made to order with a 3–4 week preparation period.",
                    icon: Icons.calendar_month,
                  ),
                  _OnboardPage(
                    title: "Design something\ntruly personal",
                    subtitle:
                        "Choose flowers, characters, colors and messages — all in one place.",
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
            ),

            // 🔘 Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => _indicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 28),

            // 🚀 CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _goToHome,
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // subtle hint
            Text(
              "You can customize anytime",
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _indicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: active ? 22 : 8,
      decoration: BoxDecoration(
        color: active ? primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🌷 Soft hero block
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _LandingPageState.primary.withOpacity(0.25),
                  _LandingPageState.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Icon(icon, size: 48, color: _LandingPageState.primary),
            ),
          ),

          const SizedBox(height: 40),

          // ✨ Headline
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: _LandingPageState.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // 🧠 Supporting text
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: _LandingPageState.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
