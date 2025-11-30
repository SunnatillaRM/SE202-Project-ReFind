import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<BitmapDescriptor> createFramedMarker(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  final Uint8List bytes = data.buffer.asUint8List();

  final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 150);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image originalImage = frame.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  const double size = 180;
  const double borderWidth = 12;
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

  final double aspect = originalImage.width / originalImage.height;
  double w, h;

  if (aspect > 1) {
    w = imageSize;
    h = imageSize / aspect;
  } else {
    h = imageSize;
    w = imageSize * aspect;
  }

  final double dx = (size - w) / 2;
  final double dy = (size - h) / 2;

  final Rect dst = Rect.fromLTWH(dx, dy, w, h);
  final Rect src = Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());

  canvas.drawImageRect(originalImage, src, dst, Paint());

  final ui.Image finished = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? finalBytes = await finished.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(finalBytes!.buffer.asUint8List());
}

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
  State<LostThingsMapPage> createState() => _LostThingsMapPageState();
}

class _LostThingsMapPageState extends State<LostThingsMapPage> {
  GoogleMapController? mapController;

  final double defaultLat = 41.2995;
  final double defaultLng = 69.2401;
  static const double minZoomToShowMarkers = 14;

  Set<Marker> markers = {};
  double currentZoom = 14;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final Set<Marker> temp = {};

    temp.add(
      Marker(
        markerId: const MarkerId("user"),
        position: LatLng(defaultLat, defaultLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You are here"),
      ),
    );

    if (widget.targetLat != null &&
        widget.targetLng != null &&
        widget.targetImagePath != null) {
      final icon = await createFramedMarker(widget.targetImagePath!);

      temp.add(
        Marker(
          markerId: const MarkerId("selected_item"),
          position: LatLng(widget.targetLat!, widget.targetLng!),
          icon: icon,
          infoWindow: InfoWindow(
            title: widget.targetTitle ?? "Item",
            snippet: widget.targetDescription ?? "",
            onTap: () => _showItemInfo(),
          ),
        ),
      );
    }

    setState(() => markers = temp);
  }

  void _showItemInfo() {
    if (widget.targetTitle == null) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.targetTitle!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (widget.targetImagePath != null)
                Image.asset(widget.targetImagePath!, width: 150),
              const SizedBox(height: 10),
              Text(widget.targetDescription ?? ""),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCameraMove(CameraPosition pos) {
    if (pos.zoom != currentZoom) {
      setState(() => currentZoom = pos.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = (widget.targetLat != null && widget.targetLng != null)
        ? LatLng(widget.targetLat!, widget.targetLng!)
        : LatLng(defaultLat, defaultLng);

    final visibleMarkers = currentZoom < minZoomToShowMarkers
        ? markers.where((m) => m.markerId.value == 'user').toSet()
        : markers;

    return Scaffold(
      appBar: AppBar(title: const Text("Lost Items Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: currentZoom,
        ),
        markers: visibleMarkers,
        onCameraMove: _onCameraMove,
        onMapCreated: (controller) => mapController = controller,
      ),
    );
  }
}
