import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/main.dart';
import 'test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('PypApp loads Login screen and allows Guest exploration', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const PypApp());
    await tester.pumpAndSettle();

    // Verify initial Login Screen is displayed
    expect(find.text('Welcome to PYP'), findsOneWidget);

    // Tap 'Explore as Guest' to enter Home Screen
    final guestBtn = find.text('Explore as Guest');
    await tester.ensureVisible(guestBtn);
    await tester.pump();
    await tester.tap(guestBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Home Screen or Discover Screen is displayed
    expect(find.text('Discover'), findsWidgets);
  });
}

