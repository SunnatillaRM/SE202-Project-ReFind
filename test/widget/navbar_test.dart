import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:se202_project_refind/widgets/navbar.dart';

void main() {
  testWidgets('AppNavbar calls onTap with correct index',
      (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox(),
          bottomNavigationBar: AppNavbar(
            currentIndex: 0,
            onTap: (i) => tappedIndex = i,
          ),
        ),
      ),
    );

    // Tap "+" tab
    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle();
    expect(tappedIndex, 1);

    // Tap map tab
    await tester.tap(find.byIcon(Icons.location_on_outlined));
    await tester.pumpAndSettle();
    expect(tappedIndex, 2);
  });
}
