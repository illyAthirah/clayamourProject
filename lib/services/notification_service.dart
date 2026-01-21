import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';
import 'package:clayamour/pages/cart_page.dart';

class NotificationService {
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;

    try {
      await FirebaseService.userSubcollection(uid, 'notifications').add({
        'title': title,
        'message': message,
        'type': type, // 'order', 'payment', 'cart'
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to add notification: $e');
    }
  }

  static Future<void> showOrderPlacedNotification(
    BuildContext context, {
    required String orderId,
    required double total,
  }) async {
    await addNotification(
      title: 'Order Placed Successfully',
      message: 'Your order #${orderId.substring(0, 8)} for RM$total has been placed.',
      type: 'order',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Order Placed Successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Order #${orderId.substring(0, 8)} - RM$total'),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> showPaymentNotification(
    BuildContext context, {
    required String status,
    required String paymentMethod,
  }) async {
    final isPaid = status.toLowerCase() == 'paid';
    final title = isPaid ? 'Payment Successful' : 'Payment Pending';
    final message = isPaid
        ? 'Your payment via $paymentMethod was successful.'
        : 'Payment pending. Please complete payment upon delivery.';

    await addNotification(
      title: title,
      message: message,
      type: 'payment',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.pending_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: isPaid ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> showAddToCartNotification(
    BuildContext context, {
    required String productName,
  }) async {
    await addNotification(
      title: 'Added to Cart',
      message: '$productName has been added to your cart.',
      type: 'cart',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$productName added to cart',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CartPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      getNotificationsStream() {
    final uid = FirebaseService.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return FirebaseService.userSubcollection(uid, 'notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  static Future<int> getUnreadCount() async {
    final uid = FirebaseService.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await FirebaseService.userSubcollection(
        uid,
        'notifications',
      ).where('read', isEqualTo: false).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;

    try {
      await FirebaseService.userSubcollection(uid, 'notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    final uid = FirebaseService.uid;
    if (uid == null) return;

    try {
      final unreadDocs = await FirebaseService.userSubcollection(
        uid,
        'notifications',
      ).where('read', isEqualTo: false).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }
}
