import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'delivery_addresses_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/services/stripe_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  bool _placing = false;
  bool _isCardComplete = false;
  final CardEditController _cardController = CardEditController();

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

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
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _placing ? null : _placeOrder,
            child: Text(
              _placing ? "Placing..." : "Place Order",
              style: const TextStyle(fontSize: 15),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseService.userSubcollection(uid, 'addresses')
              .orderBy('updatedAt', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Add a delivery address",
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              );
            }
            final data = docs.first.data();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['label']?.toString() ?? 'Address',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data['name'] ?? ''} - ${data['phone'] ?? ''}",
                        style: const TextStyle(color: textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['address']?.toString() ?? '',
                        style: const TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: items.isEmpty
          ? const Text("No selected items.")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((doc) {
                  final data = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title']?.toString() ?? 'Bouquet',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("• ${data['subtitle'] ?? ''}"),
                        if (data['theme'] != null)
                          Text(
                            "Theme: ${data['theme']}",
                            style: const TextStyle(color: textSecondary),
                          ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      "RM$total",
                      style: const TextStyle(
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

  Widget _paymentMethodCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Stripe Payment",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              Icon(Icons.check_circle, color: primary),
            ],
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: CardField(
                controller: _cardController,
                onCardChanged: (details) {
                  final complete = details?.complete ?? false;
                  if (_isCardComplete != complete) {
                    setState(() => _isCardComplete = complete);
                  }
                },
              ),
            ),
          ],
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

      final clientSecret = await StripeService.createPaymentIntent(
        amount: total * 100,
        currency: 'myr',
      );

      if (kIsWeb) {
        if (!_isCardComplete) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please complete card details.")),
          );
          return;
        }
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: const PaymentMethodData(),
          ),
        );
      } else {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'ClayAmour',
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'MY',
              testEnv: true,
            ),
            style: ThemeMode.light,
          ),
        );
        await Stripe.instance.presentPaymentSheet();
      }

      await FirebaseService.userSubcollection(uid, 'orders').add({
        'items': items,
        'total': total,
        'status': 'Placed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final doc in cartSnap.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully.")),
      );
      Navigator.pop(context);
    } on StripeException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.error.localizedMessage ?? "Payment failed")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }
}
