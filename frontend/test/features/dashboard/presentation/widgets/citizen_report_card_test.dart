import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CitizenReportCard basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Card(
              child: ListTile(
                title: Text('Test Pothole'),
                subtitle: Text('Test Location'),
              ),
            ),
          ),
        ),
      ),
    );

    // Simple text verification only
    expect(find.text('Test Pothole'), findsOneWidget);
    expect(find.text('Test Location'), findsOneWidget);
  });
}
