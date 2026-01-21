import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    required this.data,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status']?.toString() ?? 'Placed';
    final createdAt = (widget.data['createdAt'] as Timestamp?)?.toDate();
    final total = widget.data['total'] ?? 0;
    final items = (widget.data['items'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    
    // Check if order can be cancelled (within 1 hour of placement)
    final canCancel = createdAt != null &&
        status.toLowerCase() == 'placed' &&
        DateTime.now().difference(createdAt).inHours < 1;

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
            _orderHeader(status, createdAt),
            const SizedBox(height: 28),
            _orderTimeline(status),
            const SizedBox(height: 32),
            _sectionTitle("Bouquet Details"),
            const SizedBox(height: 12),
            _detailsCard(items),
            const SizedBox(height: 32),
            _paymentSummary(total),
            if (canCancel) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _cancelOrder(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Orders can only be cancelled within 1 hour of placement',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('No', style: TextStyle(fontSize: 15)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Yes, Cancel', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final uid = FirebaseService.uid;
      if (uid == null) return;

      await FirebaseService.userSubcollection(uid, 'orders')
          .doc(widget.orderId)
          .update({
        'status': 'Cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _orderHeader(String status, DateTime? createdAt) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
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
            children: [
              Text(
                "Order #${widget.orderId.substring(0, 8)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: textPrimary,
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: textSecondary),
              const SizedBox(width: 6),
              Text(
                createdAt == null ? "-" : "Placed ${_formatDate(createdAt)}",
                style: const TextStyle(color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Handcrafted with care - 3-4 weeks process",
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _orderTimeline(String status) {
    final steps = [
      "Order Placed",
      "Designing",
      "Handcrafting",
      "Ready for Collection",
    ];
    final activeIndex = _statusIndex(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Order Progress"),
        const SizedBox(height: 14),
        for (int i = 0; i < steps.length; i++)
          _timelineItem(
            title: steps[i],
            subtitle: _statusSubtitle(steps[i]),
            isCompleted: i < activeIndex,
            isActive: i == activeIndex,
            isLast: i == steps.length - 1,
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

  Widget _detailsCard(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) {
            final title = item['title']?.toString() ?? 'Bouquet';
            final subtitle = item['subtitle']?.toString() ?? '';
            final theme = item['theme']?.toString();
            final message = item['message']?.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(subtitle),
                  ],
                  if (theme != null) ...[
                    const SizedBox(height: 6),
                    Text("Theme: $theme",
                        style: const TextStyle(color: textSecondary)),
                  ],
                  if (message != null && message.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text("Message: $message",
                        style: const TextStyle(color: textSecondary)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentSummary(Object total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Paid",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Text(
            "RM$total",
            style: const TextStyle(
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

  int _statusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 3;
      case 'in progress':
        return 2;
      case 'processing':
        return 1;
      default:
        return 0;
    }
  }

  String _statusSubtitle(String step) {
    switch (step) {
      case 'Order Placed':
        return "We have received your order";
      case 'Designing':
        return "Bouquet design in progress";
      case 'Handcrafting':
        return "Clay flowers are being crafted";
      case 'Ready for Collection':
        return "Your bouquet is ready";
      default:
        return "";
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
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.15 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}


