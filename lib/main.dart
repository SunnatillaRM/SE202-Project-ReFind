import 'package:flutter/material.dart';
import 'map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ReFind - Lost & Found',
      home: LostThingsMapPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}