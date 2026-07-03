import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbcheck/main.dart';
import 'package:tbcheck/feature/auth/presentation/pages/otp_page.dart';

void main() {
  testWidgets('Login Page rendering test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'Sign in' is present.
    expect(find.text('Sign in'), findsOneWidget);

    // Verify that the 'Email' and 'Password' text field labels are present.
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify that the Login button is present.
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Sign Up Page rendering and navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Scroll 'Sign up' text into view (since test screen is 800x600 and it is at the bottom)
    final signUpTextFinder = find.text('Sign up');
    await tester.ensureVisible(signUpTextFinder);
    await tester.pumpAndSettle();

    // Tap the 'Sign up' text to transition to SignUpPage
    await tester.tap(signUpTextFinder);
    await tester.pumpAndSettle();

    // Verify that the SignUpPage title 'Sign up' is present.
    expect(find.text('Sign up'), findsOneWidget);

    // Verify that registration specific fields are present.
    expect(find.text('Phone no'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    // Verify that the 'Create Account' button is present.
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('OTP Page rendering and verification test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpPage(email: 'test@email.com'),
      ),
    );

    // Verify OTP title and email subtitle render correctly
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.textContaining('test@email.com'), findsOneWidget);

    // Verify Verify button renders
    expect(find.text('Verify'), findsOneWidget);

    // Tap Verify with empty inputs
    await tester.tap(find.text('Verify'));
    await tester.pump();

    // Verify error message is shown
    expect(find.text('Please enter all 4 digits'), findsOneWidget);

    // Fill in OTP code digits: "1", "2", "3", "4"
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(4));

    await tester.enterText(textFields.at(0), '1');
    await tester.enterText(textFields.at(1), '2');
    await tester.enterText(textFields.at(2), '3');
    await tester.enterText(textFields.at(3), '4');
    await tester.pump();

    // Tap Verify again
    await tester.tap(find.text('Verify'));
    await tester.pump();

    // Let the mock delay animation complete (simulates verification wait)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Confirms no verification error is present after entering 1234
    expect(find.textContaining('Invalid OTP code'), findsNothing);
  });
}
