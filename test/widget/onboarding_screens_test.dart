import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:se202_project_refind/screens/onboarding/welcome_screen.dart';
import 'package:se202_project_refind/screens/onboarding/get_started_screen.dart';
import 'package:se202_project_refind/screens/onboarding/verify_number_screen.dart';
import 'package:se202_project_refind/screens/onboarding/personalize_profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WelcomeScreen shows title and navigates to PersonalizeProfile',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(PersonalizeProfileScreen), findsOneWidget);
  });

  testWidgets('GetStartedScreen has phone field and Continue button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GetStartedScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Let's get started"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('VerifyNumberScreen shows code prompt and Confirm button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerifyNumberScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.text('Enter 6-digit code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('PersonalizeProfileScreen shows personalization UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalizeProfileScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Personalization'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
