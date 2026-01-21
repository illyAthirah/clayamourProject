import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/checkout_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.uid;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          "Your Cart",
          style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        ),
      ),
      body: uid == null
          ? const Center(child: Text("Please sign in to view cart."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(
                uid,
                'cart',
              ).orderBy('readyDate').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("Your cart is empty."));
                }
                final groups = _buildGroups(docs);
                final summary = _TotalSummary.fromGroups(groups);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: groups.length,
                        itemBuilder: (_, i) => _dateGroupCard(groups[i]),
                      ),
                    ),
                    _checkoutBar(summary.count, summary.total),
                  ],
                );
              },
            ),
    );
  }

  List<CartDateGroup> _buildGroups(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final Map<String, CartDateGroup> grouped = {};
    for (final doc in docs) {
      final data = doc.data();
      final readyDate =
          (data['readyDate'] as Timestamp?)?.toDate() ?? DateTime.now();
      final key = _dateKey(readyDate);
      grouped[key] ??= CartDateGroup(date: readyDate, items: []);
      grouped[key]!.items.add(CartItem.fromFirestore(doc));
    }
    final groups = grouped.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return groups;
  }

  String _dateKey(DateTime d) => "${d.year}-${d.month}-${d.day}";

  String formatDate(DateTime d) {
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

  Future<void> _pickGroupDate(CartDateGroup group) async {
    final current = group.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      for (final item in group.items) {
        await item.ref.update({'readyDate': Timestamp.fromDate(picked)});
      }
    }
  }

  void _toggleExpand(CartDateGroup group) {
    setState(() => group.expanded = !group.expanded);
  }

  Future<void> _deleteItem(CartItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text(
              'Remove Item?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove "${item.title}" from your cart?',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await item.ref.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 2),
          backgroundColor: textSecondary,
        ),
      );
    }
  }

  Future<void> _addBouquetForDate(DateTime date) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;
    final cart = FirebaseService.userSubcollection(uid, 'cart');
    await cart.add({
      'type': 'readyMade',
      'title': 'Ready-made Bouquet',
      'subtitle': 'Rose Bloom',
      'price': 89,
      'readyDate': Timestamp.fromDate(date),
      'selected': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _editTheme(CartItem item) async {
    final options = ["Soft Pink", "Pastel", "Nude", "Lavender"];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Choose theme",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              ...options.map((t) {
                final active = item.theme == t;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(t, style: const TextStyle(fontSize: 15)),
                  trailing: active
                      ? const Icon(Icons.check, color: primary)
                      : null,
                  onTap: () => Navigator.pop(context, t),
                );
              }),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await item.ref.update({'theme': selected});
    }
  }

  Future<void> _editMessage(CartItem item) async {
    final controller = TextEditingController(text: item.message ?? "");
    final newMessage = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit message"),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: "e.g. Congratulations!",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Cancel", style: TextStyle(fontSize: 15)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Save", style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );

    if (newMessage != null) {
      await item.ref.update({'message': newMessage});
    }
  }

  Widget _dateGroupCard(CartDateGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              onTap: () => _toggleExpand(group),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.15),
                      primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formatDate(group.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar, size: 20),
                      color: primary,
                      onPressed: () => _pickGroupDate(group),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: group.expanded ? 0.5 : 0.0,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: group.expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      children: [
                        ...group.items.map(_cartItemCard),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(
                              color: primary.withOpacity(0.6),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          onPressed: () => _addBouquetForDate(group.date),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            "Add another bouquet for this date",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _cartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: item.selected,
                  activeColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: (v) => item.ref.update({'selected': v ?? true}),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.red.withOpacity(0.1),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteItem(item),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (item.type == CartItemType.readyMade) ...[
            _pillRow(
              icon: Icons.local_florist,
              label: "1 item",
              value: "Bouquet A- 1",
            ),
          ] else ...[
            if (item.flowers.isNotEmpty) ...[
              _sectionMiniTitle("Flowers"),
              const SizedBox(height: 8),
              ...item.flowers.values.map((li) => _qtyLine(item, li, 'flowers')),
              const SizedBox(height: 12),
            ],
            if (item.characters.isNotEmpty) ...[
              _sectionMiniTitle("Characters"),
              const SizedBox(height: 8),
              ...item.characters.values.map(
                (li) => _qtyLine(item, li, 'characters'),
              ),
              const SizedBox(height: 12),
            ],
            _editableInfo(
              label: "Theme",
              value: item.theme ?? "-",
              onTap: () => _editTheme(item),
            ),
            const SizedBox(height: 8),
            _editableInfo(
              label: "Message",
              value: item.message ?? "-",
              onTap: () => _editMessage(item),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bouquet total",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(item.totalPrice),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primary, Color(0xFFC97C5D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "RM${item.totalPrice}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionMiniTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _qtyLine(CartItem item, CartLineItem li, String kind) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${li.name} - RM${li.unitPrice} each",
            style: const TextStyle(color: textPrimary),
          ),
        ),
        _qtyBtn(
          icon: Icons.remove,
          onTap: () async {
            if (li.qty <= 0) return;
            li.qty--;
            await _updateLineItem(item, li, kind);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "${li.qty}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _qtyBtn(
          icon: Icons.add,
          onTap: () async {
            li.qty++;
            await _updateLineItem(item, li, kind);
          },
        ),
      ],
    );
  }

  Future<void> _updateLineItem(
    CartItem item,
    CartLineItem li,
    String kind,
  ) async {
    final map = Map<String, dynamic>.from(
      kind == 'flowers' ? item.flowers : item.characters,
    );
    map[li.name] = {'name': li.name, 'unitPrice': li.unitPrice, 'qty': li.qty};
    await item.ref.update({kind: map});
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: primary.withAlpha((0.14 * 255).round()),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: primary),
        ),
      ),
    );
  }

  Widget _editableInfo({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: textPrimary, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _pillRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: textSecondary)),
        ],
      ),
    );
  }

  Widget _checkoutBar(int selectedCount, int selectedTotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Column(
                  key: ValueKey("$selectedCount-$selectedTotal"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Selected: $selectedCount bouquet${selectedCount == 1 ? "" : "s"}",
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "RM$selectedTotal",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, Color(0xFFC97C5D)],
                ),
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                onPressed: selectedCount == 0
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutPage(),
                          ),
                        );
                      },
                child: const Text(
                  "Checkout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartDateGroup {
  DateTime date;
  bool expanded;
  List<CartItem> items;

  CartDateGroup({
    required this.date,
    required this.items,
    this.expanded = true,
  });
}

enum CartItemType { readyMade, custom }

class CartItem {
  final DocumentReference<Map<String, dynamic>> ref;
  final String id;
  final CartItemType type;
  final String title;
  final String subtitle;
  final bool selected;
  final int? price;
  final int basePrice;
  final Map<String, CartLineItem> flowers;
  final Map<String, CartLineItem> characters;
  final String? theme;
  final String? message;

  CartItem._({
    required this.ref,
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.price,
    required this.basePrice,
    required this.flowers,
    required this.characters,
    required this.theme,
    required this.message,
  });

  factory CartItem.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final type = data['type'] == 'custom'
        ? CartItemType.custom
        : CartItemType.readyMade;

    final flowers = _lineItemsFromMap(data['flowers']);
    final characters = _lineItemsFromMap(data['characters']);

    return CartItem._(
      ref: doc.reference,
      id: doc.id,
      type: type,
      title: data['title']?.toString() ?? 'Bouquet',
      subtitle: data['subtitle']?.toString() ?? '',
      selected: data['selected'] == true,
      price: (data['price'] as num?)?.toInt(),
      basePrice: (data['basePrice'] as num?)?.toInt() ?? 0,
      flowers: flowers,
      characters: characters,
      theme: data['theme']?.toString(),
      message: data['message']?.toString(),
    );
  }

  static Map<String, CartLineItem> _lineItemsFromMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return {};
    return raw.map((key, value) {
      final v = value as Map<String, dynamic>;
      return MapEntry(
        key,
        CartLineItem(
          name: v['name']?.toString() ?? key,
          unitPrice: (v['unitPrice'] as num?)?.toInt() ?? 0,
          qty: (v['qty'] as num?)?.toInt() ?? 0,
        ),
      );
    });
  }

  int get totalPrice {
    if (type == CartItemType.readyMade) return price ?? 0;
    int total = basePrice;
    for (final f in flowers.values) {
      total += f.unitPrice * f.qty;
    }
    for (final c in characters.values) {
      total += c.unitPrice * c.qty;
    }
    return total;
  }
}

class CartLineItem {
  final String name;
  final int unitPrice;
  int qty;

  CartLineItem({
    required this.name,
    required this.unitPrice,
    required this.qty,
  });
}

class _TotalSummary {
  final int total;
  final int count;

  _TotalSummary(this.total, this.count);

  factory _TotalSummary.fromGroups(List<CartDateGroup> groups) {
    int total = 0;
    int count = 0;
    for (final g in groups) {
      for (final item in g.items) {
        if (item.selected) {
          total += item.totalPrice;
          count++;
        }
      }
    }
    return _TotalSummary(total, count);
  }
}
