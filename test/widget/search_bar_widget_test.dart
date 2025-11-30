import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:se202_project_refind/widgets/search_bar.dart';

void main() {
  testWidgets('SearchBarWidget shows hint and triggers onChanged',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    String lastValue = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            hintText: 'Search items...',
            onChanged: (v) => lastValue = v,
          ),
        ),
      ),
    );

    expect(find.text('Search items...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wallet');
    await tester.pump();

    expect(lastValue, 'wallet');
  });
}
