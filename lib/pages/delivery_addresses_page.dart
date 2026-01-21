import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clayamour/pages/add_address_page.dart';
import 'package:clayamour/pages/edit_address_page.dart';
import 'package:clayamour/pages/map_picker_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class DeliveryAddressesPage extends StatelessWidget {
  const DeliveryAddressesPage({super.key});

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
      body: uid == null
          ? const Center(child: Text("Please sign in to manage addresses."))
          : Column(
              children: [
                _pinLocationSection(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseService.userSubcollection(uid, 'addresses')
                        .orderBy('updatedAt', descending: true)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No addresses yet.",
                            style: TextStyle(color: textSecondary),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final selected = data['isDefault'] == true;
                          return _addressCard(
                            context: context,
                            id: doc.id,
                            label: data['label']?.toString() ?? 'Address',
                            name: data['name']?.toString() ?? '',
                            phone: data['phone']?.toString() ?? '',
                            address: data['address']?.toString() ?? '',
                            selected: selected,
                            onSelect: () => _setDefault(uid, doc.id, docs),
                          );
                        },
                      );
                    },
                  ),
                ),
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

  Widget _pinLocationSection(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await Navigator.push<LatLng>(
          context,
          MaterialPageRoute(builder: (_) => const MapPickerPage()),
        );
        if (!context.mounted || selected == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAddressPage(initialLocation: selected),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: primary.withAlpha((0.3 * 255).round())),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withAlpha((0.15 * 255).round()),
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
      ),
    );
  }

  Widget _addressCard({
    required BuildContext context,
    required String id,
    required String label,
    required String name,
    required String phone,
    required String address,
    required bool selected,
    required VoidCallback onSelect,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAddressPage(
                                addressId: id,
                              ),
                            ),
                          );
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(name, style: const TextStyle(color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(phone, style: const TextStyle(color: textSecondary)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(color: textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDefault(
    String uid,
    String selectedId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (final doc in docs) {
      await doc.reference.update({'isDefault': doc.id == selectedId});
    }
  }
}


