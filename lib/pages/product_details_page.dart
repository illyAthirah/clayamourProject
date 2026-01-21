import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/theme/app_theme.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DateTime? _readyDate;

  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color accent = AppColors.softAccent;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

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
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_florist,
          size: 80,
          color: primary.withOpacity(0.8),
        ),
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
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primary, Color(0xFFC97C5D)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "From RM$price",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.schedule, size: 20, color: primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Made to order - 3-4 weeks preparation",
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(20),
          shadowColor: Colors.black.withOpacity(0.08),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _readyDate == null
                      ? Colors.transparent
                      : primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _readyDate == null
                              ? "Select Date"
                              : _formatDate(_readyDate!),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _readyDate == null
                                ? textSecondary
                                : textPrimary,
                          ),
                        ),
                        if (_readyDate == null)
                          const Text(
                            "3-4 weeks preparation time",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                ],
              ),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, Color(0xFFC97C5D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
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

    // Validate date is selected
    if (_readyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a ready date before adding to cart'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final selectedDate = _readyDate!;
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

    await NotificationService.showAddToCartNotification(
      context,
      productName: name,
    );
  }
}
