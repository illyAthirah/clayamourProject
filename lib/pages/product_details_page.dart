import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DateTime? _readyDate;

  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFFEED6C4);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product['name']?.toString() ?? 'Product';
    final price = product['price'] ?? 0;

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
            _productInfo(name, price),
            const SizedBox(height: 28),
            _calendarSection(),
            const SizedBox(height: 36),
            _actionButtons(context, name, price),
          ],
        ),
      ),
    );
  }

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

  Widget _productInfo(String name, Object price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "From RM$price",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.schedule, size: 18, color: textSecondary),
            SizedBox(width: 6),
            Text(
              "Made to order - 3-4 weeks preparation",
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      ],
    );
  }

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
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _readyDate == null
                        ? "Select an available date (3-4 weeks preparation)"
                        : _formatDate(_readyDate!),
                    style: const TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context, String name, Object price) {
    return Column(
      children: [
        _primaryButton(
          text: "Add to Cart",
          onTap: () => _addToCart(name, price),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now.add(const Duration(days: 21)),
      firstDate: now.add(const Duration(days: 21)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _readyDate = picked);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}";
  }

  Future<void> _addToCart(String name, Object price) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;

    final selectedDate = _readyDate ?? DateTime.now().add(
      const Duration(days: 21),
    );
    final cart = FirebaseService.userSubcollection(uid, 'cart');
    await cart.add({
      'type': 'readyMade',
      'title': 'Ready-made Bouquet',
      'subtitle': name,
      'price': price,
      'readyDate': Timestamp.fromDate(selectedDate),
      'selected': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart.")),
    );
  }
}
