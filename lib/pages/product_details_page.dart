import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFFEED6C4);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(),
            const SizedBox(height: 24),
            _productInfo(),
            const SizedBox(height: 28),
            _calendarSection(),
            const SizedBox(height: 36),
            _actionButtons(context),
          ],
        ),
      ),
    );
  }

  // 🖼 Product image
  Widget _productImage() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Icon(Icons.local_florist, size: 64),
      ),
    );
  }

  // 🏷 Product info
  Widget _productInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Rose Bloom",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "From RM89",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: textSecondary),
            SizedBox(width: 6),
            Text(
              "Made to order • 3–4 weeks preparation",
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      ],
    );
  }


  // 📅 Calendar section (IMPORTANT)
  Widget _calendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Ready Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_month, color: primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Select an available date (3–4 weeks preparation)",
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  // 🔘 Action buttons
  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        _primaryButton(
          text: "Add to Cart",
          onTap: () {},
        ),
        const SizedBox(height: 12),

      ],
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }


}
