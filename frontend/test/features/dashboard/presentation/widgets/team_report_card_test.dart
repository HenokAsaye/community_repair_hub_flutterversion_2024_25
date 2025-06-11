import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_repair_hub/features/dashboard/presentation/widgets/team_report_card.dart';

void main() {
  testWidgets('TeamReportCard displays report details correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TeamReportCard(
              title: 'Test Pothole',
              location: 'Test Location',
              status: 'pending',
              priority: 'High',
              date: DateTime.now(),
            ),
          ),
        ),
      ),
    );

    // Verify that the report details are displayed
    expect(find.text('Test Pothole'), findsOneWidget);
    expect(find.text('Test Location'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('Priority: High'), findsOneWidget);
  });
}
