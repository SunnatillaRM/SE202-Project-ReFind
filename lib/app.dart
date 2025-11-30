import 'package:flutter/material.dart';
import '/screens/home/home_screen.dart';
import '/screens/add_item/add_item_screen.dart';
import '/screens/map_view/map_screen.dart';
import '/widgets/navbar.dart';
import '/database/mock_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Refind",
      debugShowCheckedModeBanner: false,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _index = 0;
  bool _isInitialized = false;

  List<Widget> get pages => [
    const HomeScreen(),
    const AddItemScreen(),
    const MapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      print('AppRoot: Starting database initialization...');
      await MockData.initializeMockData();
      print('AppRoot: Database initialization complete');
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing database: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: AppNavbar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
