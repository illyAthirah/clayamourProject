import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:flutter/material.dart';

class CustomizeBouquetPage extends StatefulWidget {
  const CustomizeBouquetPage({super.key});

  @override
  State<CustomizeBouquetPage> createState() => _CustomizeBouquetPageState();
}

class _CustomizeBouquetPageState extends State<CustomizeBouquetPage> {
  String _selectedTheme = "Soft Pink";
  final List<String> _themes = ["Soft Pink", "Nude", "Pastel", "Lavender"];
  String _customMessage = "";
  DateTime? _readyDate;

  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  // Selected items
  final Map<String, _Item> _selectedItems = {};

  int get _totalPrice {
    int total = 0;
    for (final item in _selectedItems.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

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
          "Customize Bouquet",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Build your bouquet"),
            if (_selectedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "No items selected yet",
                  style: TextStyle(color: textSecondary),
                ),
              )
            else
              Column(
                children: _selectedItems.values
                    .map((item) => _selectedItemCard(item))
                    .toList(),
              ),
            _addButton("Add Flowers", "Flowers"),
            const SizedBox(height: 8),
            _addButton("Add Characters", "Characters"),
            const SizedBox(height: 32),
            _sectionTitle("Personalize it"),
            _sectionSub("Bouquet Theme"),
            _themeSelector(),
            const SizedBox(height: 20),
            _sectionSub("Custom Message"),
            _messageField(),
            const SizedBox(height: 32),
            _sectionTitle("Finalize your order"),
            _sectionSub("Ready Date"),
            _calendarPicker(),
            const SizedBox(height: 28),
            _priceSummary(),
            const SizedBox(height: 16),
            _addToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _sectionSub(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _selectedItemCard(_Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: primary.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_florist, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "RM${item.price} each",
                  style: const TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(Icons.remove, () {
                setState(() {
                  item.quantity--;
                  if (item.quantity <= 0) {
                    _selectedItems.remove(item.name);
                  }
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("${item.quantity}"),
              ),
              _qtyButton(Icons.add, () {
                setState(() => item.quantity++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _themes.map((theme) {
        final selected = _selectedTheme == theme;
        return ChoiceChip(
          label: Text(theme),
          selected: selected,
          selectedColor: primary.withAlpha((0.2 * 255).round()),
          labelStyle: TextStyle(
            color: selected ? primary : textPrimary,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => setState(() => _selectedTheme = theme),
        );
      }).toList(),
    );
  }

  Widget _messageField() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        maxLines: 2,
        maxLength: 50,
        decoration: const InputDecoration(
          hintText: "E.g. Congratulations!",
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (v) => setState(() => _customMessage = v),
      ),
    );
  }

  Widget _addButton(String label, String category) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () => _showPicker(category, label),
      child: Text(label),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: primary.withAlpha((0.15 * 255).round()),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: primary),
        ),
      ),
    );
  }

  void _showPicker(String category, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseService.products()
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = snap.data?.docs.map((d) {
                  final data = d.data();
                  return _Item(
                    d.id,
                    data['name']?.toString() ?? 'Item',
                    (data['price'] ?? 0) as int,
                    category: category,
                  );
                }).toList() ??
                <_Item>[];

            return _pickerContent(items, title);
          },
        );
      },
    );
  }

  Widget _pickerContent(List<_Item> items, String title) {
    List<_Item> filtered = List.from(items);
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  setModalState(() {
                    filtered = items
                        .where((i) =>
                            i.name.toLowerCase().contains(v.toLowerCase()))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (_, i) => _pickerGridCard(filtered[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pickerGridCard(_Item item) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _selectedItems[item.name] =
                _selectedItems[item.name] ?? item.copy();
            _selectedItems[item.name]!.quantity++;
          });
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: primary.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_florist,
                      size: 36,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                "RM${item.price}",
                style: const TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarPicker() {
    return InkWell(
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
                style: const TextStyle(color: textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Total Price",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        Text(
          "RM$_totalPrice",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _addToCartButton() {
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: _addToCart,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: const Text(
            "Add Bouquet to Cart",
            style: TextStyle(
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

  Future<void> _addToCart() async {
    final uid = FirebaseService.uid;
    if (uid == null) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select items first.")),
      );
      return;
    }

    final flowers = <String, dynamic>{};
    final characters = <String, dynamic>{};
    for (final item in _selectedItems.values) {
      final entry = {
        'name': item.name,
        'unitPrice': item.price,
        'qty': item.quantity,
      };
      if (item.category == 'Characters') {
        characters[item.name] = entry;
      } else {
        flowers[item.name] = entry;
      }
    }

    final selectedDate = _readyDate ?? DateTime.now().add(
      const Duration(days: 21),
    );
    await FirebaseService.userSubcollection(uid, 'cart').add({
      'type': 'custom',
      'title': 'Custom Bouquet',
      'subtitle': _selectedTheme,
      'basePrice': 0,
      'flowers': flowers,
      'characters': characters,
      'theme': _selectedTheme,
      'message': _customMessage,
      'readyDate': Timestamp.fromDate(selectedDate),
      'selected': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom bouquet added to cart.")),
    );
    setState(() {
      _selectedItems.clear();
      _customMessage = "";
    });
  }
}

class _Item {
  final String id;
  final String name;
  final int price;
  final String category;
  int quantity;

  _Item(this.id, this.name, this.price, {this.category = "Custom"})
      : quantity = 0;

  _Item copy() => _Item(id, name, price, category: category);
}

