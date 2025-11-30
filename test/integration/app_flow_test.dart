import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Full app flow integration test is skipped in automated runs',
    (WidgetTester tester) async {
      // In this environment we skip full end-to-end flow
      // (requires plugins, maps, and real devices).
      // The flow is exercised manually / on a device instead.
    },
    skip: true,
  );
}
