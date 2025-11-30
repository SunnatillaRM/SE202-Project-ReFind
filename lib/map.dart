import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<BitmapDescriptor> createFramedMarker(String imagePath) async {
  // Load image
  final ByteData data = await rootBundle.load(imagePath);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 150);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image originalImage = frameInfo.image;

  // Create canvas
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  final double size = 180.0; // total marker size
  final double borderWidth = 12.0; // thicker border
  final double imageSize = size - 2 * borderWidth; // inner image size

  // Draw border (white)
  final Paint borderPaint = Paint()
    ..color = Colors.blueGrey
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(24),
    ),
    borderPaint,
  );

  // Calculate aspect ratio for the image
  final double imgAspect = originalImage.width / originalImage.height;
  double dstWidth, dstHeight;
  if (imgAspect > 1) {
    // Wide image
    dstWidth = imageSize;
    dstHeight = imageSize / imgAspect;
  } else {
    // Tall image
    dstHeight = imageSize;
    dstWidth = imageSize * imgAspect;
  }

  // Center the image inside the border
  final double dx = (size - dstWidth) / 2;
  final double dy = (size - dstHeight) / 2;

  final Rect dstRect = Rect.fromLTWH(dx, dy, dstWidth, dstHeight);
  final Paint paint = Paint();
  canvas.drawImageRect(
    originalImage,
    Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
    dstRect,
    paint,
  );

  // Convert to BitmapDescriptor
  final ui.Image finalImage = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

class LostThingsMapPage extends StatefulWidget {
  const LostThingsMapPage({super.key});

  @override
  _LostThingsMapPageState createState() => _LostThingsMapPageState();
}

class _LostThingsMapPageState extends State<LostThingsMapPage> {
  GoogleMapController? mapController;

  final LatLng userLocation = LatLng(41.2995, 69.2401); // Tashkent

  final List<Map<String, dynamic>> items = [
    {
      "title": "Wallet",
      "description": "Black leather wallet found near the bus stop.",
      "lat": 41.311081,
      "lng": 69.240562,
      "image": "assets/images/wallet.png"
    },
    {
      "title": "Keys",
      "description": "Set of car keys found in the park.",
      "lat": 41.315081,
      "lng": 69.245562,
      "image": "assets/images/keys.png"
    }
  ];

  Set<Marker> markers = {};
  double currentZoom = 14; // initial zoom
  final double minZoomToShowMarkers = 14; // threshold zoom

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  void loadMarkers() async {
    Set<Marker> tempMarkers = {};
    for (var item in items) {
      final customIcon = await createFramedMarker(item['image']);
      tempMarkers.add(
        Marker(
          markerId: MarkerId(item['title']),
          position: LatLng(item['lat'], item['lng']),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: item['title'],
            snippet: item['description'],
            onTap: () => showItemDetails(item),
          ),
        ),
      );
    }

    // Add user marker
    tempMarkers.add(
      Marker(
        markerId: MarkerId('user'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: "You are here"),
      ),
    );

    setState(() {
      markers = tempMarkers;
    });
  }

  void showItemDetails(item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Image.asset(item['image'], width: 150),
              SizedBox(height: 10),
              Text(item['description']),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              )
            ],
          ),
        );
      },
    );
  }

  void onCameraMove(CameraPosition position) {
    // Update current zoom
    if (position.zoom != currentZoom) {
      setState(() {
        currentZoom = position.zoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show markers if zoom >= minZoomToShowMarkers
    Set<Marker> visibleMarkers = currentZoom >= minZoomToShowMarkers
        ? markers
        : markers.where((m) => m.markerId.value == 'user').toSet(); // only show user marker if zoomed out

    return Scaffold(
      appBar: AppBar(title: Text("Lost Items Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: userLocation,
          zoom: currentZoom,
        ),
        markers: visibleMarkers,
        onCameraMove: onCameraMove,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}