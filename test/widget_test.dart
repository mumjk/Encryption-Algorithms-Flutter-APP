// This is a basic Flutter widget test for Lab 06 Crypto App
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Crypto Lab app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CryptoLabApp());

    // Verify that the app title is displayed
    expect(find.text('Lab 06 - Review of Encryption Algorithms'), findsOneWidget);

    // Verify that Caesar tab is shown by default
    expect(find.text('Task 1: Caesar Cipher'), findsOneWidget);
  });

  testWidgets('Navigation between tasks works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CryptoLabApp());

    // Verify we start at Caesar Cipher
    expect(find.text('Task 1: Caesar Cipher'), findsOneWidget);

    // Tap on the Mono-Alpha tab
    await tester.tap(find.text('Mono-Alpha'));
    await tester.pumpAndSettle();

    // Verify we're now at Mono-Alphabetic page
    expect(find.text('Task 2: Mono-Alphabetic Substitution'), findsOneWidget);

    // Tap on the Vigenère tab
    await tester.tap(find.text('Vigenère'));
    await tester.pumpAndSettle();

    // Verify we're now at Vigenère page
    expect(find.text('Task 3: Vigenère Cipher'), findsOneWidget);

    // Tap on the DES tab
    await tester.tap(find.text('DES'));
    await tester.pumpAndSettle();

    // Verify we're now at DES page
    expect(find.text('Task 4: DES Encryption'), findsOneWidget);

    // Tap on the AES tab
    await tester.tap(find.text('AES'));
    await tester.pumpAndSettle();

    // Verify we're now at AES page
    expect(find.text('Task 5: AES Encryption'), findsOneWidget);
  });
}