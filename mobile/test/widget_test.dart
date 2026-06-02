// This is a basic Flutter widget test for DesktopNaotuMobileApp.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_assistant/main.dart';

void main() {
  testWidgets('Smoke test - Verify home screen elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DesktopNaotuMobileApp());

    // Allow mock loader and parser to process
    await tester.pumpAndSettle();

    // Verify that the title '桌面版脑图 · 移动助手' is present.
    expect(find.text('桌面版脑图 · 移动助手'), findsOneWidget);

    // Verify that our mock mind map root node title is present.
    expect(find.textContaining('Electron 无边框与毛玻璃重构'), findsOneWidget);

    // Verify that action buttons exist.
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}

