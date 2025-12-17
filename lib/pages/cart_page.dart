import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  late List<CartDateGroup> groups;

  @override
  void initState() {
    super.initState();

    // Dummy cart grouped by date
    groups = [
      CartDateGroup(
        date: DateTime(2025, 5, 12),
        items: [
          CartItem.readyMade(
            id: "rm_rose_bloom",
            title: "Ready-made Bouquet",
            subtitle: "Rose Bloom",
            price: 89,
          ),
          CartItem.custom(
            id: "cus_1",
            title: "Custom Bouquet",
            subtitle: "Personalized Design",
            basePrice: 0,
            flowers: {
              "Rose": CartLineItem(name: "Rose", unitPrice: 8, qty: 10),
              "Lily": CartLineItem(name: "Lily", unitPrice: 7, qty: 10),
            },
            characters: {
              "Graduate": CartLineItem(name: "Graduate", unitPrice: 25, qty: 1),
            },
            theme: "Pastel",
            message: "Congratulations!",
          ),
        ],
      ),
      CartDateGroup(
        date: DateTime(2025, 5, 20),
        items: [
          CartItem.custom(
            id: "cus_2",
            title: "Custom Bouquet",
            subtitle: "Soft Pink Theme",
            basePrice: 0,
            flowers: {
              "Sunflower": CartLineItem(name: "Sunflower", unitPrice: 6, qty: 12),
            },
            characters: {},
            theme: "Soft Pink",
            message: "For You 💗",
          ),
        ],
      ),
    ];
  }

  int get selectedTotal {
    int total = 0;
    for (final g in groups) {
      for (final item in g.items) {
        if (item.selected) total += item.totalPrice;
      }
    }
    return total;
  }

  int get selectedCount {
    int c = 0;
    for (final g in groups) {
      for (final item in g.items) {
        if (item.selected) c++;
      }
    }
    return c;
  }

  String formatDate(DateTime d) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}";
  }

  Future<void> _pickGroupDate(int groupIndex) async {
    final current = groups[groupIndex].date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      setState(() => groups[groupIndex].date = picked);
    }
  }

  void _toggleExpand(int groupIndex) {
    setState(() => groups[groupIndex].expanded = !groups[groupIndex].expanded);
  }

  void _deleteItem(int groupIndex, String itemId) {
    setState(() {
      groups[groupIndex].items.removeWhere((i) => i.id == itemId);
      if (groups[groupIndex].items.isEmpty) {
        groups.removeAt(groupIndex);
      }
    });
  }

  void _addBouquetForDate(int groupIndex) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Add bouquet for this date",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _sheetTile(
                  icon: Icons.local_florist,
                  title: "Ready-made bouquet",
                  subtitle: "Add a design bouquet",
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      groups[groupIndex].items.add(
                        CartItem.readyMade(
                          id: "rm_${DateTime.now().millisecondsSinceEpoch}",
                          title: "Ready-made Bouquet",
                          subtitle: "Rose Bloom",
                          price: 89,
                        ),
                      );
                      groups[groupIndex].expanded = true;
                    });
                  },
                ),
                _sheetTile(
                  icon: Icons.auto_awesome,
                  title: "Custom bouquet",
                  subtitle: "Build your own bouquet",
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      groups[groupIndex].items.add(
                        CartItem.custom(
                          id: "cus_${DateTime.now().millisecondsSinceEpoch}",
                          title: "Custom Bouquet",
                          subtitle: "New Custom Design",
                          basePrice: 0,
                          flowers: {
                            "Rose": CartLineItem(name: "Rose", unitPrice: 8, qty: 6),
                          },
                          characters: {},
                          theme: "Pastel",
                          message: "Your message",
                        ),
                      );
                      groups[groupIndex].expanded = true;
                    });
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
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
                  trailing: active ? const Icon(Icons.check, color: primary) : null,
                  onTap: () => Navigator.pop(context, t),
                );
              }),
            ],
          ),
        );
      },
    );

    if (selected != null) setState(() => item.theme = selected);
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newMessage != null) setState(() => item.message = newMessage);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: groups.length,
              itemBuilder: (_, groupIndex) => _dateGroupCard(groupIndex),
            ),
          ),
          _checkoutBar(),
        ],
      ),
    );
  }

  // ✅ Date Group UI (with animation)
  Widget _dateGroupCard(int groupIndex) {
    final g = groups[groupIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Date Header (highlighted + edit + expand)
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _toggleExpand(groupIndex),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formatDate(g.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),

                  // Edit date
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: textPrimary,
                    onPressed: () => _pickGroupDate(groupIndex),
                  ),

                  // Expand indicator (animated)
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: g.expanded ? 0.5 : 0.0,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),

          // Expand/collapse animation
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: g.expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        ...g.items.map((item) => _cartItemCard(groupIndex, item)),
                        const SizedBox(height: 6),

                        // Add another bouquet for this date
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary.withOpacity(0.55)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _addBouquetForDate(groupIndex),
                          icon: const Icon(Icons.add),
                          label: const Text("Add another bouquet for this date"),
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

  // ✅ Individual item card (checkbox + edit qty/theme/message + delete)
  Widget _cartItemCard(int groupIndex, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: item.selected,
                activeColor: primary,
                onChanged: (v) => setState(() => item.selected = v ?? true),
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
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteItem(groupIndex, item.id),
              ),
            ],
          ),

          const Divider(height: 18),

          // Content differs by type
          if (item.type == CartItemType.readyMade) ...[
            _pillRow(
              icon: Icons.local_florist,
              label: "1 item",
              value: "Bouquet × 1",
            ),
          ] else ...[
            // Flowers
            if (item.flowers.isNotEmpty) ...[
              _sectionMiniTitle("Flowers"),
              const SizedBox(height: 6),
              ...item.flowers.values.map((li) => _qtyLine(li)),
              const SizedBox(height: 10),
            ],

            // Characters
            if (item.characters.isNotEmpty) ...[
              _sectionMiniTitle("Characters"),
              const SizedBox(height: 6),
              ...item.characters.values.map((li) => _qtyLine(li)),
              const SizedBox(height: 10),
            ],

            // Theme + Message (editable)
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

          // Price row (animated when selected changes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bouquet total",
                style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
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

  // Qty line with + / -
  Widget _qtyLine(CartLineItem li) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${li.name} • RM${li.unitPrice} each",
            style: const TextStyle(color: textPrimary),
          ),
        ),
        _qtyBtn(
          icon: Icons.remove,
          onTap: () {
            setState(() {
              if (li.qty > 0) li.qty--;
            });
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
          onTap: () => setState(() => li.qty++),
        ),
      ],
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: primary.withOpacity(0.14),
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

  Widget _pillRow({required IconData icon, required String label, required String value}) {
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
            style: const TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: textSecondary)),
        ],
      ),
    );
  }

  // ✅ Checkout bar: shows selected count + selected total
  Widget _checkoutBar() {
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
          )
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
                      style: const TextStyle(color: textSecondary, fontSize: 12),
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
                onPressed: selectedCount == 0 ? null : () {},
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

/* ===========================
   Models (dummy)
   =========================== */

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
  final String id;
  final CartItemType type;

  final String title;
  final String subtitle;

  bool selected;

  // Ready-made
  int? price;

  // Custom
  int basePrice;
  Map<String, CartLineItem> flowers;
  Map<String, CartLineItem> characters;

  String? theme;
  String? message;

  CartItem._({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.price,
    required this.basePrice,
    required this.flowers,
    required this.characters,
    this.theme,
    this.message,
  });

  factory CartItem.readyMade({
    required String id,
    required String title,
    required String subtitle,
    required int price,
  }) {
    return CartItem._(
      id: id,
      type: CartItemType.readyMade,
      title: title,
      subtitle: subtitle,
      selected: true,
      price: price,
      basePrice: 0,
      flowers: {},
      characters: {},
    );
  }

  factory CartItem.custom({
    required String id,
    required String title,
    required String subtitle,
    required int basePrice,
    required Map<String, CartLineItem> flowers,
    required Map<String, CartLineItem> characters,
    required String theme,
    required String message,
  }) {
    return CartItem._(
      id: id,
      type: CartItemType.custom,
      title: title,
      subtitle: subtitle,
      selected: true,
      price: null,
      basePrice: basePrice,
      flowers: flowers,
      characters: characters,
      theme: theme,
      message: message,
    );
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
