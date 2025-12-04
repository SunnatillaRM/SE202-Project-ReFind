import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/models/item.dart';
import '/database/database_service.dart';
import '/screens/map_view/map_screen.dart';

class ItemCard extends StatefulWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final db = DatabaseService();
  String? firstImage;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    firstImage = await db.getFirstImageByItemId(widget.item.itemId!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to map with item's coordinates
        final itemLocation = LatLng(widget.item.latitude, widget.item.longitude);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              initialLocation: itemLocation,
              highlightItemId: widget.item.itemId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                image: firstImage == null
                    ? null
                    : DecorationImage(
                        image: AssetImage(firstImage!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Text section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.addressText ?? "Unknown location",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
