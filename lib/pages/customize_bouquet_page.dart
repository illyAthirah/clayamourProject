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

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  // Selected items (dummy)
  final Map<String, _Item> _selectedItems = {};

  // Dummy catalogue
  final List<_Item> _flowers = [
    _Item("Rose", 8, "assets/flowers/rose.png"),
    _Item("Lily", 7, "assets/flowers/lily.png"),
    _Item("Sunflower", 6, "assets/flowers/sunflower.png"),
  ];

  final List<_Item> _characters = [
    _Item("Lotso", 15, "assets/chars/lotso.png"),
    _Item("Graduate", 25, "assets/chars/graduate.png"),
  ];

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

            _addButton("Add Flowers", _flowers),
            const SizedBox(height: 8),
            _addButton("Add Characters", _characters),

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
            _calendarPlaceholder(),

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
              color: primary.withOpacity(0.15),
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
                  style:
                      const TextStyle(fontSize: 13, color: textSecondary),
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
          selectedColor: primary.withOpacity(0.2),
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

  Widget _addButton(String label, List<_Item> source) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () => _showPicker(source, label),
      child: Text(label),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: primary.withOpacity(0.15),
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

  void _showPicker(List<_Item> items, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
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
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.local_florist,
                          size: 36,
                          color: primary,
                        );
                      },
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
                style:
                    const TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_month, color: primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Select an available date (3–4 weeks preparation)",
              style: TextStyle(color: textSecondary),
            ),
          ),
        ],
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
        onTap: () {},
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
}

// =========================
// Item model (dummy)
// =========================
class _Item {
  final String name;
  final int price;
  final String image;
  int quantity;

  _Item(this.name, this.price, this.image, {this.quantity = 0});

  _Item copy() => _Item(name, price, image);
}
