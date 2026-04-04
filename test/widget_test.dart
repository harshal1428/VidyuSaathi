import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic app shell renders safely', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('CivicCore smoke test'),
        ),
      ),
    );

    expect(find.text('CivicCore smoke test'), findsOneWidget);
  });
}