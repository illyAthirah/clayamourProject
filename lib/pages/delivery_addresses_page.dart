import 'package:flutter/material.dart';
import 'package:clayamour/pages/add_address_page.dart';
import 'package:clayamour/pages/edit_address_page.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({super.key});

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  int _selectedIndex = 0;

  final List<_Address> _addresses = [
    _Address(
      label: "Home",
      name: "Dinie Athirah",
      phone: "012-3456789",
      address: "UTHM,\n83000 Batu Pahat, Johor",
    ),
    _Address(
      label: "Work",
      name: "Nurul Najma",
      phone: "012-3456789",
      address: "Bumbung Biru,\n83000 Batu Pahat, Johor",
    ),
  ];

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
          "Delivery Address",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: Column(
        children: [
          _pinLocationSection(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                final bool selected = index == _selectedIndex;

                return _addressCard(
                  address: address,
                  selected: selected,
                  onSelect: () {
                    setState(() => _selectedIndex = index);
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditAddressPage(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ➕ Add new address
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAddressPage()),
                );
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text("Add New Address"),
            ),
          ),
        ],
      ),
    );
  }

  // 📍 Dummy pin location section
  Widget _pinLocationSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: primary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pin your current location",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Use GPS to auto-fill your delivery address",
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: textSecondary),
        ],
      ),
    );
  }

  // 🏠 Address card
  Widget _addressCard({
    required _Address address,
    required bool selected,
    required VoidCallback onSelect,
    required VoidCallback onEdit,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio indicator
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? primary : Colors.grey,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: onEdit,
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(address.name,
                      style: const TextStyle(color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(address.phone,
                      style: const TextStyle(color: textSecondary)),
                  const SizedBox(height: 6),
                  Text(address.address,
                      style: const TextStyle(color: textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🧱 Address model (dummy)
class _Address {
  final String label;
  final String name;
  final String phone;
  final String address;

  _Address({
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
  });
}
