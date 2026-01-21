import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/checkout_page.dart';
import 'package:clayamour/services/firebase_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final Map<String, bool> _expandedState = {};

  String _cartItemImage(CartItem item) {
    final name = item.subtitle.toLowerCase();

    final fileName = name
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '_');

    if (item.type == CartItemType.custom) {
      return 'assets/single/$fileName.png';
    }

    // ready-made bouquets
    return 'assets/flowers/$fileName.png';
  }

  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

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

      grouped[key] ??= CartDateGroup(
        date: readyDate,
        items: [],
        expanded: _expandedState[key] ?? true,
      );

      grouped[key]!.items.add(CartItem.fromFirestore(doc));
    }

    return grouped.values.toList()..sort((a, b) => a.date.compareTo(b.date));
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
  setState(() {
    group.expanded = !group.expanded;
    _expandedState[_dateKey(group.date)] = group.expanded;
  });
}

  Future<void> _deleteItem(CartItem item) async {
    await item.ref.delete();
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
                  title: Text(t),
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
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newMessage != null) {
      await item.ref.update({'message': newMessage});
    }
  }

  Widget _bouquetThumbnail(CartItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        height: 56,
        color: background,
        child: Image.asset(
          _cartItemImage(item),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.local_florist,
              color: Colors.grey,
              size: 28,
            );
          },
        ),
      ),
    );
  }

  Widget _dateGroupCard(CartDateGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _toggleExpand(group),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: BoxDecoration(
                color: primary.withAlpha((0.10 * 255).round()),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formatDate(group.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: textPrimary,
                    onPressed: () => _pickGroupDate(group),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: group.expanded ? 0.5 : 0.0,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: group.expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        ...group.items.map(_cartItemCard),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(
                              color: primary.withAlpha((0.55 * 255).round()),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _addBouquetForDate(group.date),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            "Add another bouquet for this date",
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bouquetThumbnail(item),
              const SizedBox(width: 12),

              Checkbox(
                value: item.selected,
                activeColor: primary,
                onChanged: (v) => item.ref.update({'selected': v ?? true}),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteItem(item),
              ),
            ],
          ),

          const Divider(height: 18),
          if (item.type == CartItemType.readyMade) ...[
            _pillRow(
              icon: Icons.local_florist,
              label: "1 item",
              value: "Bouquet A- 1",
            ),
          ] else ...[
            if (item.flowers.isNotEmpty) ...[
              _sectionMiniTitle("Flowers"),
              const SizedBox(height: 6),
              ...item.flowers.values.map((li) => _qtyLine(item, li, 'flowers')),
              const SizedBox(height: 10),
            ],
            if (item.characters.isNotEmpty) ...[
              _sectionMiniTitle("Characters"),
              const SizedBox(height: 6),
              ...item.characters.values.map((li) {
                final fileName = li.name
                    .toLowerCase()
                    .replaceAll('&', 'and')
                    .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
                    .replaceAll(' ', '_');

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/characters/$fileName.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

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
                        await _updateLineItem(item, li, 'characters');
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
                        await _updateLineItem(item, li, 'characters');
                      },
                    ),
                  ],
                );
              }),

              const SizedBox(height: 10),
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
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bouquet total",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  "RM${item.totalPrice}",
                  key: ValueKey(item.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primary,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
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
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "RM$selectedTotal",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                  style: TextStyle(fontWeight: FontWeight.w700),
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
  if (raw == null || raw is! Map<String, dynamic>) {
    return <String, CartLineItem>{};
  }

  final Map<String, CartLineItem> result = {};

  raw.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      result[key] = CartLineItem(
        name: value['name']?.toString() ?? key,
        unitPrice: (value['unitPrice'] as num?)?.toInt() ?? 0,
        qty: (value['qty'] as num?)?.toInt() ?? 0,
      );
    }
  });

  return result;
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
