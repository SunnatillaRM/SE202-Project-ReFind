import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/get_started_screen.dart';

void main() {
  runApp(const ReFindApp());
}

class ReFindApp extends StatelessWidget {
  const ReFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReFind',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // uses app_theme.dart
      home: const GetStartedScreen(), // your flow starts here
    );
  }
}
