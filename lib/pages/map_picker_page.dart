import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clayamour/theme/app_theme.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const LatLng _defaultLocation = LatLng(1.8631, 103.0900);

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  CameraPosition get _initialCameraPosition {
    return CameraPosition(
      target: widget.initialLocation ?? _defaultLocation,
      zoom: widget.initialLocation == null ? 14 : 16,
    );
  }

  Set<Marker> get _markers {
    if (_selectedLocation == null) return {};
    return {
      Marker(
        markerId: const MarkerId('selected'),
        position: _selectedLocation!,
      ),
    };
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
  }

  void _confirmSelection() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap the map to drop a pin first.")),
      );
      return;
    }
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final supportsMap =
        kIsWeb || defaultTargetPlatform == TargetPlatform.android;
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
          "Pin Location",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              "Tap on the map to drop a pin for your delivery location.",
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: supportsMap
                    ? GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        onTap: _onMapTap,
                        markers: _markers,
                        zoomControlsEnabled: false,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                      )
                    : Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          "Google Maps is only supported on Android and Web in this app.",
                          style: TextStyle(color: textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: supportsMap ? _confirmSelection : null,
                child: const Text(
                  "Use This Location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
