import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clayamour/pages/map_picker_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class AddAddressPage extends StatefulWidget {
  final LatLng? initialLocation;

  const AddAddressPage({super.key, this.initialLocation});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _label = "Home";
  bool _hasPinned = false;
  String _pinnedText = "Pin location to auto-fill address";
  LatLng? _pinnedLocation;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _applyPinnedLocation(widget.initialLocation!, overwriteAddress: true);
    }
  }

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
              onTap: () async {
                final selected = await Navigator.push<LatLng>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MapPickerPage(initialLocation: _pinnedLocation),
                  ),
                );
                if (!mounted || selected == null) return;
                setState(() {
                  _applyPinnedLocation(
                    selected,
                    overwriteAddress: _addressCtrl.text.trim().isEmpty,
                  );
                });
              },
            ),
            const SizedBox(height: 22),
            _sectionTitle("Full Address"),
            _multilineField(label: "Address", controller: _addressCtrl),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        color: background,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            onPressed: _saving ? null : _saveAddress,
            child: Text(
              _saving ? "Saving..." : "Save Address",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          selectedColor: primary.withAlpha((0.18 * 255).round()),
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
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: textSecondary),
          ),
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
            color: _hasPinned
                ? primary.withAlpha((0.45 * 255).round())
                : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withAlpha((0.15 * 255).round()),
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
                    style: const TextStyle(fontSize: 13, color: textSecondary),
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

  String _formatLatLng(LatLng location) {
    return "${location.latitude.toStringAsFixed(6)}, "
        "${location.longitude.toStringAsFixed(6)}";
  }

  void _applyPinnedLocation(LatLng location, {bool overwriteAddress = false}) {
    _pinnedLocation = location;
    _hasPinned = true;
    _pinnedText = "Pinned: ${_formatLatLng(location)}";
    setState(() {});
  }

  Future<void> _saveAddress() async {
    final uid = FirebaseService.uid;
    if (uid == null) return;
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'label': _label,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_pinnedLocation != null) {
        payload['latitude'] = _pinnedLocation!.latitude;
        payload['longitude'] = _pinnedLocation!.longitude;
      }
      await FirebaseService.userSubcollection(uid, 'addresses').add(payload);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
