import 'package:flutter/material.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  String _label = "Home";

  // Dummy pinned location state
  bool _hasPinned = false;
  String _pinnedText = "Pin location to auto-fill address";

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
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
          "Add New Address",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Address Label"),
            _labelChips(),
            const SizedBox(height: 22),

            _sectionTitle("Recipient Details"),
            _inputField(label: "Full Name", controller: _nameCtrl),
            _inputField(label: "Phone Number", controller: _phoneCtrl),
            const SizedBox(height: 10),

            _sectionTitle("Pin Location"),
            _pinLocationBox(
              onTap: () {
                // ✅ UI-only dummy
                setState(() {
                  _hasPinned = true;
                  _pinnedText = "Pinned: UTHM, Batu Pahat (dummy)";
                  _addressCtrl.text =
                      "UTHM,\n83000 Batu Pahat, Johor\nMalaysia";
                });
              },
            ),
            const SizedBox(height: 22),

            _sectionTitle("Full Address"),
            _multilineField(label: "Address", controller: _addressCtrl),
          ],
        ),
      ),

      // Save button
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
            onPressed: () {
              // later → save to backend
              Navigator.pop(context);
            },
            child: const Text(
              "Save Address",
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _labelChips() {
    final labels = ["Home", "Work", "Other"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: labels.map((l) {
        final selected = _label == l;
        return ChoiceChip(
          label: Text(l),
          selected: selected,
          selectedColor: primary.withOpacity(0.18),
          labelStyle: TextStyle(
            color: selected ? primary : textPrimary,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => setState(() => _label = l),
        );
      }).toList(),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _multilineField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // 📍 Pin location box (dummy UI)
  Widget _pinLocationBox({required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hasPinned ? primary.withOpacity(0.45) : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.location_on_outlined, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasPinned ? "Location pinned" : "Pin your location",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pinnedText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
