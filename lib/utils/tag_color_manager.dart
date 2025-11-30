import 'package:flutter/material.dart';
import 'dart:math';

class TagColorManager {
  static final TagColorManager _instance = TagColorManager._internal();
  factory TagColorManager() => _instance;
  TagColorManager._internal();

  final Map<String, Color> _tagColors = {};

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];

  final Random _random = Random();

  Color getColorForTag(String tag) {
    if (_tagColors.containsKey(tag)) {
      return _tagColors[tag]!;
    }

    final color = _availableColors[_random.nextInt(_availableColors.length)];

    _tagColors[tag] = color;
    return color;
  }
}
