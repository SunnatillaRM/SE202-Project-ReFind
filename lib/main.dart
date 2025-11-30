import 'package:flutter/material.dart';
import 'map.dart';
import 'screens/home_page.dart'; // <-- make sure this path matches your project

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReFind',
      // Start from Home page instead of map
      home: const HomePage(),
      // Keep the map page available as a named route
      routes: {
        '/map': (context) => LostThingsMapPage(),
      },
    ),
  );
}
