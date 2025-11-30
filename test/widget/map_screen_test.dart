import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'MapScreen widget test is skipped (covered via integration tests)',
    (WidgetTester tester) async {
      // Intentionally left empty.
      // MapScreen depends on Google Maps / platform views and is exercised
      // in integration tests instead of a pure widget test environment.
    },
    skip: true,
  );
}
