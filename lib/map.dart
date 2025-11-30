import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'database/database_service.dart';
import 'database/mock_data.dart';
import 'models/item.dart';

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
  @override
  _LostThingsMapPageState createState() => _LostThingsMapPageState();
}

class _LostThingsMapPageState extends State<LostThingsMapPage> {
  GoogleMapController? mapController;
  final DatabaseService _dbService = DatabaseService();

  final LatLng userLocation = LatLng(41.2995, 69.2401); // Tashkent

  List<Item> items = [];
  Set<Marker> markers = {};
  double currentZoom = 14; // initial zoom
  final double minZoomToShowMarkers = 14; // threshold zoom
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      // Initialize mock data
      await MockData.initializeMockData();
      // Load items from database
      await loadMarkers();
    } catch (e) {
      print('Error initializing database: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMarkers() async {
    try {
      // Get all active items from database
      final dbItems = await _dbService.getActiveItems();
      
      Set<Marker> tempMarkers = {};
      
      for (var item in dbItems) {
        // Get first image for the item
        final imagePath = await _dbService.getFirstImageByItemId(item.itemId!);
        
        BitmapDescriptor icon;
        if (imagePath != null) {
          try {
            icon = await createFramedMarker(imagePath);
          } catch (e) {
            // If image loading fails, use default marker
            icon = BitmapDescriptor.defaultMarkerWithHue(
              item.type == 'lost' 
                ? BitmapDescriptor.hueRed 
                : BitmapDescriptor.hueGreen
            );
          }
        } else {
          // Use default marker if no image
          icon = BitmapDescriptor.defaultMarkerWithHue(
            item.type == 'lost' 
              ? BitmapDescriptor.hueRed 
              : BitmapDescriptor.hueGreen
          );
        }

        tempMarkers.add(
          Marker(
            markerId: MarkerId('item_${item.itemId}'),
            position: LatLng(item.latitude, item.longitude),
            icon: icon,
            infoWindow: InfoWindow(
              title: item.title,
              snippet: item.description ?? '',
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
        items = dbItems;
        markers = tempMarkers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading markers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showItemDetails(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<String?>(
          future: _dbService.getFirstImageByItemId(item.itemId!),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(
                          item.type.toUpperCase(),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        backgroundColor: item.type == 'lost' ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (snapshot.hasData && snapshot.data != null)
                    Image.asset(snapshot.data!, width: 150, height: 150, fit: BoxFit.cover)
                  else
                    Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  SizedBox(height: 10),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(item.description!),
                  if (item.addressText != null && item.addressText!.isNotEmpty) ...[
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            item.addressText!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
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