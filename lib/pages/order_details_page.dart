import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

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
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orderHeader(),
            const SizedBox(height: 28),
            _orderTimeline(),
            const SizedBox(height: 32),
            _sectionTitle("Bouquet Details"),
            const SizedBox(height: 12),
            _detailsCard(),
            const SizedBox(height: 32),
            _paymentSummary(),
          ],
        ),
      ),
    );
  }

  // 🧾 Strong order header
  Widget _orderHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Order CA-10212",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: textPrimary,
                ),
              ),
              _StatusBadge(),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: textSecondary),
              SizedBox(width: 6),
              Text(
                "Ready by 20 May 2025",
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Handcrafted with care • 3–4 weeks process",
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ],
      ),
    );
  }

  // 🕒 Order timeline
  Widget _orderTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Order Progress"),
        const SizedBox(height: 14),

        _timelineItem(
          title: "Order Placed",
          subtitle: "We have received your order",
          isCompleted: true,
          isActive: false,
        ),
        _timelineItem(
          title: "Designing",
          subtitle: "Bouquet design in progress",
          isCompleted: true,
          isActive: false,
        ),
        _timelineItem(
          title: "Handcrafting",
          subtitle: "Clay flowers are being crafted",
          isCompleted: false,
          isActive: true,
        ),
        _timelineItem(
          title: "Ready for Collection",
          subtitle: "Your bouquet is ready",
          isCompleted: false,
          isActive: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _timelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? primary
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? primary : textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🌸 Bouquet details
  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Custom Bouquet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text("• Rose × 10"),
          Text("• Lily × 10"),
          Text("• Graduate Character × 1"),
          SizedBox(height: 14),
          Text("Theme: Pastel", style: TextStyle(color: textSecondary)),
          SizedBox(height: 6),
          Text(
            "Message: Congratulations!",
            style: TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }

  // 💰 Payment summary
  Widget _paymentSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Total Paid",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Text(
            "RM235",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );
  }
}

// 🟣 Status badge widget
class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "In Progress",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }
}
