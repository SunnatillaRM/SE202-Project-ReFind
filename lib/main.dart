import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No database calls — mock data only.
  runApp(const MyApp());
}
