import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '/database/database_service.dart';
import '/models/item.dart';
import '/models/item_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final DatabaseService _db = DatabaseService();

  Set<Marker> markers = {};
  double currentZoom = 14;
  final double minZoomToShowMarkers = 14;
  final LatLng userLocation = const LatLng(41.2995, 69.2401);

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final List<Item> items = await _db.getActiveItems();
    Set<Marker> temp = {};

    for (final item in items) {
      final String? imagePath = await _db.getFirstImageByItemId(item.itemId!);

      final BitmapDescriptor icon = imagePath != null
          ? await _createFramedMarker(imagePath)
          : BitmapDescriptor.defaultMarker;

      temp.add(
        Marker(
          markerId: MarkerId(item.itemId.toString()),
          position: LatLng(item.latitude, item.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: item.title,
            snippet: item.description ?? '',
            onTap: () => _showItemDetails(item, imagePath),
          ),
        ),
      );
    }

    // Add user marker
    temp.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You are here"),
      ),
    );

    setState(() => markers = temp);
  }

  // ---------------------------------------------------------------------
  //   CUSTOM MARKER IMAGE FRAME
  // ---------------------------------------------------------------------
  Future<BitmapDescriptor> _createFramedMarker(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 150);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    const double size = 180.0;
    const double borderWidth = 12.0;
    const double imageSize = size - 2 * borderWidth;

    final Paint borderPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size),
        const Radius.circular(24),
      ),
      borderPaint,
    );

    // aspect ratio
    final double ratio = originalImage.width / originalImage.height;
    double w, h;
    if (ratio > 1) {
      w = imageSize;
      h = imageSize / ratio;
    } else {
      h = imageSize;
      w = imageSize * ratio;
    }

    final double dx = (size - w) / 2;
    final double dy = (size - h) / 2;

    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      Rect.fromLTWH(dx, dy, w, h),
      Paint(),
    );

    final ui.Image finalImage = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  }

  // ---------------------------------------------------------------------
  //   SHOW ITEM DETAILS BOTTOM SHEET
  // ---------------------------------------------------------------------
  void _showItemDetails(Item item, String? imagePath) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (imagePath != null)
              Image.asset(imagePath, width: 160)
            else
              const Icon(Icons.image_not_supported, size: 80),
            const SizedBox(height: 12),
            Text(item.description ?? "No description."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final visibleMarkers = currentZoom >= minZoomToShowMarkers
        ? markers
        : markers.where((m) => m.markerId.value == 'user').toSet();

    return Scaffold(
      appBar: AppBar(title: const Text("Lost Items Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: userLocation, zoom: currentZoom),
        markers: visibleMarkers,
        onCameraMove: (pos) => setState(() => currentZoom = pos.zoom),
        onMapCreated: (c) => mapController = c,
      ),
    );
  }
}
