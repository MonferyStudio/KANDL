import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stockos/main.dart';

void main() {
  testWidgets('Stockos app smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const StockosApp());

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
