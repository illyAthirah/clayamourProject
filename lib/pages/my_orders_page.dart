import 'package:flutter/material.dart';
import 'package:clayamour/pages/order_details_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

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
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _orderCard(
            context: context,
            orderId: "CA-10231",
            status: "In Progress",
            statusColor: Colors.orange,
            readyDate: "12 May 2025",
            items: const ["Rose Bloom Bouquet × 1"],
            total: "RM89",
          ),
          _orderCard(
            context: context,
            orderId: "CA-10212",
            status: "Processing",
            statusColor: Colors.blue,
            readyDate: "20 May 2025",
            items: const ["Rose × 10", "Lily × 10", "Graduate Character × 1"],
            total: "RM235",
          ),
          _orderCard(
            context: context,
            orderId: "CA-10198",
            status: "Completed",
            statusColor: Colors.green,
            readyDate: "02 April 2025",
            items: const ["Sunflower Bouquet × 1"],
            total: "RM79",
          ),
        ],
      ),
    );
  }

  // 🧾 Order card
  Widget _orderCard({
    required BuildContext context,
    required String orderId,
    required String status,
    required Color statusColor,
    required String readyDate,
    required List<String> items,
    required String total,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order $orderId",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      item,
                      style: const TextStyle(color: textPrimary),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          _infoRow("Ready Date", readyDate),

          const Divider(height: 24),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderDetailsPage()),
                  );
                },
                child: const Text("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 13, color: textSecondary),
        ),
        Text(value, style: const TextStyle(fontSize: 13, color: textPrimary)),
      ],
    );
  }
}
