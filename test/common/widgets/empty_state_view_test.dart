import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/primary_button.dart';

void main() {
  group('EmptyStateView Widget Tests', () {
    testWidgets('renders title, message, icon and actions properly', (
      tester,
    ) async {
      var primaryPressed = false;
      var secondaryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Camera Access Denied',
              message: 'Please enable camera in settings to scan your skin.',
              icon: Icons.no_photography_outlined,
              primaryActionLabel: 'Try Again',
              onPrimaryAction: () => primaryPressed = true,
              secondaryActionLabel: 'Cancel',
              onSecondaryAction: () => secondaryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Camera Access Denied'), findsOneWidget);
      expect(
        find.text('Please enable camera in settings to scan your skin.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.no_photography_outlined), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(primaryPressed, isTrue);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(secondaryPressed, isTrue);
    });

    testWidgets('renders custom illustration instead of icon when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Custom State',
              message: 'Custom description',
              illustration: SizedBox(
                key: Key('custom-illustration'),
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-illustration')), findsOneWidget);
      expect(find.text('Custom State'), findsOneWidget);
      expect(find.text('Custom description'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsNothing);
    });
  });
}
