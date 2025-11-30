import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:se202_project_refind/screens/location_picker/location_picker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LocationPickerScreen shows map and confirm button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LocationPickerScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // GoogleMap is present
    expect(find.byType(GoogleMap), findsOneWidget);

    // Confirm button
    expect(find.text('Use this location'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
