
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selected;

  // Start over Tashkent (you can change this)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(41.2995, 69.2401), // Tashkent
    zoom: 14,
  );

  void _onMapTap(LatLng position) {
    setState(() {
      _selected = position;
    });
  }

  void _onConfirm() {
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick location')),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _mapController = controller,
        onTap: _onMapTap,
        markers: _selected == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selected!,
                ),
              },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onConfirm,
        icon: const Icon(Icons.check),
        label: const Text('Use this location'),
      ),
    );
  }
}
