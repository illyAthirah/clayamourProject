import 'package:flutter/material.dart';
import 'delivery_addresses_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

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
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Delivery Address"),
            _addressCard(context),
            const SizedBox(height: 28),

            _sectionTitle("Order Summary"),
            _orderSummaryCard(),
            const SizedBox(height: 28),

            _sectionTitle("Payment Method"),
            _paymentMethodCard(),
          ],
        ),
      ),

      // 🔒 Place order button
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        color: background,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              // later → place order API
            },
            child: const Text(
              "Place Order",
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  // 🏠 Address section
  Widget _addressCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeliveryAddressesPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Home",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Aqilah Joharudin • 012-3456789",
                    style: TextStyle(color: textSecondary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "No 12, Jalan Pintas Puding, Batu Pahat, Johor",
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  // 📦 Order summary
  Widget _orderSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
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
          SizedBox(height: 8),
          Text("• Rose × 10"),
          Text("• Lily × 10"),
          Text("• Graduate Character × 1"),
          SizedBox(height: 10),
          Text(
            "Theme: Pastel",
            style: TextStyle(color: textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            "Ready Date: 20 May 2025",
            style: TextStyle(color: textSecondary),
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                "RM235",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💳 Payment method
  Widget _paymentMethodCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: const [
          Icon(Icons.account_balance_wallet_outlined, color: primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Online Banking / E-Wallet",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: primary),
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
