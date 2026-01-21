import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'delivery_addresses_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/services/toyyibpay_service.dart';
import 'package:clayamour/services/notification_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  bool _placing = false;
  String _selectedPaymentMethod = 'toyyibpay'; // 'toyyibpay' or 'cod'

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.uid;
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
      body: uid == null
          ? const Center(child: Text("Please sign in to checkout."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(uid, 'cart')
                  .where('selected', isEqualTo: true)
                  .snapshots(),
              builder: (context, cartSnap) {
                final items = cartSnap.data?.docs ?? [];
                final total = items.fold<int>(0, (runningTotal, doc) {
                  final data = doc.data();
                  final price = (data['price'] as num?)?.toInt() ?? 0;
                  final base = (data['basePrice'] as num?)?.toInt() ?? 0;
                  final flowers = _sumLineItems(data['flowers']);
                  final characters = _sumLineItems(data['characters']);
                  return runningTotal + price + base + flowers + characters;
                });

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Delivery Address"),
                      _addressCard(context, uid),
                      const SizedBox(height: 28),
                      _sectionTitle("Order Summary"),
                      _orderSummaryCard(items, total),
                      const SizedBox(height: 28),
                      _sectionTitle("Payment Method"),
                      _paymentMethodCard(),
                    ],
                  ),
                );
              },
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        color: background,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: _placing ? null : _placeOrder,
            child: Text(
              _placing ? "Placing..." : "Place Order",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  int _sumLineItems(dynamic raw) {
    if (raw is! Map<String, dynamic>) return 0;
    int total = 0;
    for (final v in raw.values) {
      if (v is Map<String, dynamic>) {
        final unit = (v['unitPrice'] as num?)?.toInt() ?? 0;
        final qty = (v['qty'] as num?)?.toInt() ?? 0;
        total += unit * qty;
      }
    }
    return total;
  }

  Widget _addressCard(BuildContext context, String uid) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeliveryAddressesPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseService.userSubcollection(uid, 'addresses')
              .orderBy('updatedAt', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_location_alt, color: primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Add a delivery address",
                      style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                ],
              );
            }
            final data = docs.first.data();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['label']?.toString() ?? 'Address',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${data['name'] ?? ''} - ${data['phone'] ?? ''}",
                        style: const TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['address']?.toString() ?? '',
                        style: const TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, size: 18, color: primary),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _orderSummaryCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
    int total,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: items.isEmpty
          ? const Text("No selected items.")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((doc) {
                  final data = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title']?.toString() ?? 'Bouquet',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "• ${data['subtitle'] ?? ''}",
                          style: const TextStyle(fontSize: 13, color: textSecondary),
                        ),
                        if (data['theme'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Theme: ${data['theme']}",
                              style: const TextStyle(color: textSecondary, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primary, Color(0xFFC97C5D)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "RM$total",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _paymentMethodCard() {
    return Column(
      children: [
        _paymentOption(
          'toyyibpay',
          'toyyibPay',
          Icons.account_balance_wallet_outlined,
          'FPX Online Banking & e-Wallets',
        ),
        const SizedBox(height: 12),
        _paymentOption(
          'cod',
          'Cash on Delivery',
          Icons.money_outlined,
          'Pay when you receive',
        ),
      ],
    );
  }

  Widget _paymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    return Material(
      elevation: isSelected ? 4 : 2,
      borderRadius: BorderRadius.circular(20),
      shadowColor: isSelected ? primary.withOpacity(0.3) : Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primary : textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? textPrimary : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: primary),
            ],
          ),
        ),
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

  Future<void> _placeOrder() async {
    final uid = FirebaseService.uid;
    if (uid == null) return;

    setState(() => _placing = true);
    try {
      final cartSnap = await FirebaseService.userSubcollection(uid, 'cart')
          .where('selected', isEqualTo: true)
          .get();
      if (cartSnap.docs.isEmpty) return;

      final items = cartSnap.docs.map((d) => d.data()).toList();
      int total = 0;
      for (final data in items) {
        final price = (data['price'] as num?)?.toInt() ?? 0;
        final base = (data['basePrice'] as num?)?.toInt() ?? 0;
        final flowers = _sumLineItems(data['flowers']);
        final characters = _sumLineItems(data['characters']);
        total += price + base + flowers + characters;
      }

      if (total <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to process zero total.")),
        );
        return;
      }

      bool paymentSuccess = false;

      // Process payment based on selected method
      if (_selectedPaymentMethod == 'cod') {
        // COD doesn't require payment now
        paymentSuccess = true;
      } else {
        // Process payment with toyyibPay
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Get phone from user profile or use default
        String phoneNumber = user.phoneNumber ?? '';
        if (phoneNumber.isEmpty) {
          phoneNumber = '0123456789'; // Default phone if not available
        }

        final paymentUrl = await ToyyibPayService.createBill(
          billName: 'ClayAmour Order',
          billDescription: 'Payment for bouquet order',
          amountInRM: total,
          customerName: user.displayName ?? 'Customer',
          customerEmail: user.email ?? 'customer@clayamour.com',
          customerPhone: phoneNumber,
          callbackUrl: 'https://clayamour.com/payment-callback',
        );

        if (paymentUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to create payment. Please check the debug console for details."),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        // Open toyyibPay payment page
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          if (!mounted) return;
          // Show dialog to confirm payment
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Payment Confirmation'),
              content: const Text(
                'Have you completed the payment?\n\n'
                'Click "Yes" after successful payment, or "Cancel" if you cancelled the payment.',
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, I Paid', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment cancelled.")),
            );
            return;
          }
          
          paymentSuccess = true;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open payment page.")),
          );
          return;
        }
      }

      final orderRef = await FirebaseService.userSubcollection(uid, 'orders').add({
        'items': items,
        'total': total,
        'status': 'Placed',
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': _selectedPaymentMethod == 'cod' ? 'Pending' : 'Paid',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final doc in cartSnap.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;

      // Show order placed notification
      await NotificationService.showOrderPlacedNotification(
        context,
        orderId: orderRef.id,
        total: total.toDouble(),
      );

      if (!mounted) return;

      // Show payment notification
      await NotificationService.showPaymentNotification(
        context,
        status: _selectedPaymentMethod == 'cod' ? 'Pending' : 'Paid',
        paymentMethod: _selectedPaymentMethod == 'cod' ? 'Cash on Delivery' : 'toyyibPay',
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }
}

