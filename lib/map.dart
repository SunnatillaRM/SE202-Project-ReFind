import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Creates a framed marker icon from an asset image.
Future<BitmapDescriptor> createFramedMarker(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec =
      await ui.instantiateImageCodec(bytes, targetWidth: 150);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image originalImage = frameInfo.image;

  const double size = 180.0;
  const double imageSize = 120.0;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  // Background & border
  final Paint bgPaint = Paint()..color = Colors.white;
  final Paint borderPaint = Paint()
    ..color = Colors.black.withOpacity(0.2)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  final RRect outerRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(24),
  );
  canvas.drawRRect(outerRect, bgPaint);
canvas.drawRRect(outerRect, borderPaint);


  // Keep image aspect ratio
  final double imgAspect =
      originalImage.width.toDouble() / originalImage.height.toDouble();
  double dstWidth, dstHeight;
  if (imgAspect > 1) {
    dstWidth = imageSize;
    dstHeight = imageSize / imgAspect;
  } else {
    dstHeight = imageSize;
    dstWidth = imageSize * imgAspect;
  }

  final double imgLeft = (size - dstWidth) / 2;
  final double imgTop = (size - dstHeight) / 2 - 10;

  final Rect srcRect = Rect.fromLTWH(
    0,
    0,
    originalImage.width.toDouble(),
    originalImage.height.toDouble(),
  );
  final Rect dstRect = Rect.fromLTWH(imgLeft, imgTop, dstWidth, dstHeight);

  canvas.drawImageRect(originalImage, srcRect, dstRect, Paint());

  // Pointer triangle
  final Path pointerPath = Path()
    ..moveTo(size / 2 - 10, size - 24)
    ..lineTo(size / 2 + 10, size - 24)
    ..lineTo(size / 2, size)
    ..close();
  canvas.drawPath(pointerPath, bgPaint);
  canvas.drawPath(pointerPath, borderPaint);

  final ui.Image finalImage =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await finalImage.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

/// Map page.
///
/// - Open from bottom nav: LostThingsMapPage()
/// - Open from Home item:  LostThingsMapPage(
///       targetLat: item.lat,
///       targetLng: item.lng,
///       targetTitle: item.title,
///   )
class LostThingsMapPage extends StatefulWidget {
  final double? targetLat;
  final double? targetLng;
  final String? targetTitle;
  final String? targetDescription;
  final String? targetImagePath;

  const LostThingsMapPage({
    super.key,
    this.targetLat,
    this.targetLng,
    this.targetTitle,
    this.targetDescription,
    this.targetImagePath,
  });

  @override
  _LostThingsMapPageState createState() => _LostThingsMapPageState();
}

class _LostThingsMapPageState extends State<LostThingsMapPage> {
  GoogleMapController? mapController;
  MarkerId? selectedMarkerId;

  // Approx user location (Tashkent)
  final LatLng userLocation = const LatLng(41.2995, 69.2401);

  // ALL items that should always appear on the map
  final List<Map<String, dynamic>> items = const [
    {
      "title": "Wireless Headphones",
      "description": "Noise-cancelling over-ear headphones, almost new.",
      "lat": 41.311081,
      "lng": 69.240562,
      "image": "assets/images/headphone.jpg",
    },
    {
      "title": "Smartphone (Samsung A52)",
      "description": "Found near bus stop, black case with cracked corner.",
      "lat": 41.315081,
      "lng": 69.245562,
      "image": "assets/images/samsung.jpg",
    },
    {
      "title": "Black Hoodie",
      "description": "Plain black hoodie, size M.",
      "lat": 41.320000,
      "lng": 69.250000,
      "image": "assets/images/hoodie.jpg",
    },
    {
      "title": "Blue Backpack",
      "description": "School backpack with keychain on zipper.",
      "lat": 41.305000,
      "lng": 69.230000,
      "image": "assets/images/backpack.jpg",
    },
    {
      "title": "Data Structures Book",
      "description": "English CS textbook left in reading room.",
      "lat": 41.310500,
      "lng": 69.247000,
      "image": "assets/images/book.jpg",
    },
    {
      "title": "Office Chair",
      "description": "Ergonomic chair, slightly damaged armrest.",
      "lat": 41.298000,
      "lng": 69.240000,
      "image": "assets/images/chair.jpg",
    },
    {
      "title": "Keychain with 3 Keys",
      "description": "Metal keychain with smiley face.",
      "lat": 41.299500,
      "lng": 69.241500,
      "image": "assets/images/keys.jpg",
    },
  ];

  Set<Marker> markers = {};
  double currentZoom = 14;
  final double minZoomToShowMarkers = 14;

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  /// Create markers for:
  /// - all items (framed image markers)
  /// - user location
  void loadMarkers() async {
    final Set<Marker> tempMarkers = {};
    MarkerId? selectedId;

    for (final item in items) {
      final title = item['title'] as String;
      final image = item['image'] as String;

      final icon = await createFramedMarker(image);
      final markerId = MarkerId(title);

      // Remember which marker corresponds to selected item (if any)
      if (widget.targetTitle != null && widget.targetTitle == title) {
        selectedId = markerId;
      }

      tempMarkers.add(
        Marker(
          markerId: markerId,
          position: LatLng(item['lat'] as double, item['lng'] as double),
          icon: icon,
          infoWindow: InfoWindow(
            title: title,
            snippet: item['description'] as String,
            onTap: () => showItemDetails(item),
          ),
        ),
      );
    }

    // user marker
    tempMarkers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
        infoWindow: const InfoWindow(title: "You are here"),
      ),
    );

    setState(() {
      markers = tempMarkers;
      selectedMarkerId = selectedId;
    });
  }

  void showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item['image'] != null)
              Image.asset(
                item['image'] as String,
                width: 150,
              ),
            const SizedBox(height: 10),
            Text(item['description'] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void onCameraMove(CameraPosition position) {
    if (position.zoom != currentZoom) {
      setState(() {
        currentZoom = position.zoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // At far zoom, show just user + (optionally) selected item;
    // when zoomed in enough, show all markers.
    final Set<Marker> visibleMarkers;
    if (currentZoom >= minZoomToShowMarkers) {
      visibleMarkers = markers;
    } else {
      visibleMarkers = markers
          .where((m) =>
              m.markerId.value == 'user' ||
              (selectedMarkerId != null &&
                  m.markerId == selectedMarkerId))
          .toSet();
    }

    final LatLng initialTarget = (widget.targetLat != null &&
            widget.targetLng != null)
        ? LatLng(widget.targetLat!, widget.targetLng!)
        : userLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost Items Map"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: currentZoom,
        ),
        markers: visibleMarkers,
        onCameraMove: onCameraMove,
        onMapCreated: (controller) async {
          mapController = controller;

          // If opened from Home with a specific item → zoom and show its info window.
          if (widget.targetLat != null && widget.targetLng != null) {
            await controller.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(widget.targetLat!, widget.targetLng!),
                  zoom: 16,
                ),
              ),
            );

            if (selectedMarkerId != null) {
              // Wait a frame so markers are added, then show popup
              await Future.delayed(const Duration(milliseconds: 300));
              controller.showMarkerInfoWindow(selectedMarkerId!);
            }
          }
        },
      ),
    );
  }
}
