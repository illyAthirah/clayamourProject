import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help Center",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            const SizedBox(height: 24),

            _sectionTitle("Orders & Production"),
            _faqTile(
              "How long does it take to make a bouquet?",
              "ClayAmour bouquets are handcrafted after payment. "
              "Preparation usually takes 3–4 weeks depending on design complexity.",
            ),
            _faqTile(
              "Why do I need to select a ready date?",
              "Because each bouquet is made to order, the ready date helps us plan crafting time properly.",
            ),
            _faqTile(
              "Can I change my order after checkout?",
              "Minor changes may be allowed before crafting begins. Please contact support as soon as possible.",
            ),

            const SizedBox(height: 24),

            _sectionTitle("Delivery & Collection"),
            _faqTile(
              "Do you offer delivery?",
              "Yes. You can choose delivery or self-collection during checkout.",
            ),
            _faqTile(
              "What happens if I miss my collection date?",
              "Please inform us early. We will store your bouquet for a limited time.",
            ),

            const SizedBox(height: 24),

            _sectionTitle("Custom Bouquet"),
            _faqTile(
              "How does custom bouquet work?",
              "You can choose flowers, characters, theme colors, and add a custom message before checkout.",
            ),
            _faqTile(
              "Will the colors look exactly like the photos?",
              "Clay bouquets are handmade. Slight color variations may occur, making each piece unique.",
            ),

            const SizedBox(height: 24),

            _sectionTitle("Payments & Account"),
            _faqTile(
              "What payment methods are supported?",
              "We support online payments. More options will be added soon.",
            ),
            _faqTile(
              "Is my payment secure?",
              "Yes. All payments are processed securely using trusted platforms.",
            ),

            const SizedBox(height: 32),

            _contactSupportCard(),
          ],
        ),
      ),
    );
  }

  // 🔍 Search bar (UI only)
  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for help",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔤 Section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  // ❓ FAQ tile (Material 3 ExpansionTile style)
  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 📞 Contact support
  Widget _contactSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Need more help?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Contact our support team for assistance",
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
