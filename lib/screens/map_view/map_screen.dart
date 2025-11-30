import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<BitmapDescriptor> createFramedMarker(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 150);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image originalImage = frameInfo.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  final double size = 180.0;
  final double borderWidth = 12.0;
  final double imageSize = size - 2 * borderWidth;

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

  final double imgAspect = originalImage.width / originalImage.height;
  double dstWidth, dstHeight;
  if (imgAspect > 1) {
    dstWidth = imageSize;
    dstHeight = imageSize / imgAspect;
  } else {
    dstHeight = imageSize;
    dstWidth = imageSize * imgAspect;
  }

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

  final ui.Image finalImage = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

class LostThingsMapPage extends StatefulWidget {
  @override
  _LostThingsMapPageState createState() => _LostThingsMapPageState();
}

class _LostThingsMapPageState extends State<LostThingsMapPage> {
  GoogleMapController? mapController;

  final LatLng userLocation = LatLng(41.2995, 69.2401);

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
  double currentZoom = 14;
  final double minZoomToShowMarkers = 14;

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
    if (position.zoom != currentZoom) {
      setState(() {
        currentZoom = position.zoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> visibleMarkers = currentZoom >= minZoomToShowMarkers
        ? markers
        : markers.where((m) => m.markerId.value == 'user').toSet();

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