import 'package:flutter/material.dart';
import '../utils/tag_color_manager.dart';

class Tag extends StatefulWidget {
  final String label;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const Tag({
    super.key,
    required this.label,
    this.selected = false,
    this.interactive = false,
    this.onTap,
    this.onRemove,
  });

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final Color color = TagColorManager().getColorForTag(widget.label.toLowerCase());

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 20,
        constraints: const BoxConstraints(minWidth: 40),
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        decoration: BoxDecoration(
          color: widget.selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Text(
              widget.label,
              style: TextStyle(
                color: widget.selected ? Colors.white : color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (widget.interactive && widget.selected) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: widget.selected ? Colors.white : color,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
