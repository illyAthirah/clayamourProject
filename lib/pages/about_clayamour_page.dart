import 'package:flutter/material.dart';

class AboutClayAmourPage extends StatelessWidget {
  const AboutClayAmourPage({super.key});

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
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About ClayAmour",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _brandHeader(),
            const SizedBox(height: 28),
            _infoCard(
              title: "Our Story",
              content:
                  "ClayAmour was created to turn meaningful moments into timeless keepsakes. "
                  "Every bouquet is handcrafted with love, designed to last forever without fading.",
            ),
            const SizedBox(height: 20),
            _infoCard(
              title: "What Makes Us Special",
              content:
                  "• 100% handmade clay flowers\n"
                  "• Made-to-order bouquets\n"
                  "• Fully customizable designs\n"
                  "• Long-lasting & maintenance-free",
            ),
            const SizedBox(height: 20),
            _infoCard(
              title: "How It Works",
              content:
                  "1. Choose a ready-made or custom bouquet\n"
                  "2. Select colors, message & ready date\n"
                  "3. We handcraft your bouquet\n"
                  "4. Ready for collection or delivery",
            ),
            const SizedBox(height: 32),
            _footer(),
          ],
        ),
      ),
    );
  }

  // 🌸 Brand header
  Widget _brandHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_florist,
            size: 40,
            color: primary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "ClayAmour",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Handcrafted Clay Bouquets",
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // 📄 Info card
  Widget _infoCard({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ℹ️ Footer
  Widget _footer() {
    return Column(
      children: const [
        Text(
          "Version 1.0.0",
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
        SizedBox(height: 6),
        Text(
          "© 2026 ClayAmour. All rights reserved.",
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
      ],
    );
  }
}
