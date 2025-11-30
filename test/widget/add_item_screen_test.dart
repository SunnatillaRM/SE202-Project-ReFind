import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:se202_project_refind/screens/add_item/add_item_screen.dart';
import 'package:se202_project_refind/database/database_service.dart';
import 'package:se202_project_refind/database/mock_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use web/in-memory DB so tests don't touch real SQLite
    DatabaseService.forceWebMode();
    await MockData.initializeMockData();
  });

  tearDownAll(() {
    DatabaseService.resetWebMode();
  });

  testWidgets('AddItemScreen builds without throwing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddItemScreen(),
      ),
    );

    // Let any async init finish
    await tester.pumpAndSettle();

    // Just verify the screen is there
    expect(find.byType(AddItemScreen), findsOneWidget);
  });
}
