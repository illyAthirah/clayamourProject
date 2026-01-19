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

  void _goToAuth() {
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
            // 🔹 Top bar with Skip
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goToAuth,
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              ),
            ),

            // 🔹 Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: const [
                  _OnboardPage(
                    title: "Handcrafted bouquets\nmade just for them",
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

            const SizedBox(height: 24),

            // 🚀 CTA (ONLY on last page)
            if (_currentPage == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _goToAuth,
                    child: const Text(
                      "Start Designing",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _indicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
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

// =======================================================
// Onboarding Page (Animated)
// =======================================================

class _OnboardPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<_OnboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌸 Hero Card
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _LandingPageState.primary.withAlpha((0.35 * 255).round()),
                      _LandingPageState.primary.withAlpha((0.08 * 255).round()),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 56,
                    color: _LandingPageState.primary,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: _LandingPageState.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: _LandingPageState.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

