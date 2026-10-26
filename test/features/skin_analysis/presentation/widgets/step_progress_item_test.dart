import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/step_progress_item.dart';

void main() {
  testWidgets('renders title and completed checkmark when completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StepProgressItem(
            title: 'Analysing scan results...',
            state: StepProgressState.completed,
          ),
        ),
      ),
    );

    expect(find.text('Analysing scan results...'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('renders active progress indicator when active', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StepProgressItem(
            title: 'Building scan report...',
            state: StepProgressState.active,
          ),
        ),
      ),
    );

    expect(find.text('Building scan report...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
