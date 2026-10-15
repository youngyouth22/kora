import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/widgets/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets(
      'renders button with default primary gradient and ink splash',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Default Button',
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Default Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        // Verify default gradient is AppGradients.primary
        final decoratedBoxes = tester.widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(DecoratedBox),
          ),
        );

        final matchingBox = decoratedBoxes.firstWhere(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient ==
                  AppGradients.primary,
        );
        final decoration = matchingBox.decoration as BoxDecoration;
        expect(decoration.gradient, equals(AppGradients.primary));

        // Verify InkWell exists for ripple effect
        expect(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(InkWell),
          ),
          findsOneWidget,
        );

        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'cancels gradient when explicit backgroundColor is supplied',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Solid Color',
                backgroundColor: AppColors.error,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify no DecoratedBox with gradient exists
        final decoratedBoxes = tester.widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(DecoratedBox),
          ),
        );

        final hasGradientBox = decoratedBoxes.any(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient != null,
        );
        expect(hasGradientBox, isFalse);

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(
          elevatedButton.style?.backgroundColor?.resolve({}),
          AppColors.error,
        );
      },
    );

    testWidgets(
      'renders custom gradient and custom border with retained ink response',
      (tester) async {
        var tapped = false;

        const customGradient = LinearGradient(
          colors: [AppPrimaryColors.shade400, AppPrimaryColors.shade800],
        );
        const borderSide = BorderSide(
          color: AppPrimaryColors.shade900,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Custom Gradient',
                gradient: customGradient,
                side: borderSide,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        final decoratedBoxes = tester.widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(DecoratedBox),
          ),
        );

        final matchingBox = decoratedBoxes.firstWhere(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient == customGradient,
        );
        final decoration = matchingBox.decoration as BoxDecoration;
        expect(decoration.gradient, equals(customGradient));

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PrimaryButton)),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'when isDisabled is true, removes gradient and border, applies shade100, '
      'preserves text color, and blocks clicks',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Disabled Action',
                isDisabled: true,
                side: const BorderSide(
                  color: AppPrimaryColors.shade900,
                ),
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        // Interaction blocked
        expect(button.onPressed, isNull);

        // No gradient applied
        final decoratedBoxes = tester.widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(DecoratedBox),
          ),
        );
        final hasGradient = decoratedBoxes.any(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient != null,
        );
        expect(hasGradient, isFalse);

        // No border applied
        expect(button.style?.side?.resolve({WidgetState.disabled}), isNull);

        // Button background color becomes AppPrimaryColors.shade100
        expect(
          button.style?.backgroundColor?.resolve({
            WidgetState.disabled,
          }),
          AppPrimaryColors.shade100,
        );

        // Text color remains equal to effectiveTextColor (white by default)
        expect(
          button.style?.foregroundColor?.resolve({
            WidgetState.disabled,
          }),
          AppGreyColors.white,
        );

        final textWidget = tester.widget<Text>(find.text('Disabled Action'));
        expect(textWidget.style?.color, AppGreyColors.white);

        // Tap attempt should not invoke onPressed
        await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
        await tester.pump();
        expect(tapped, isFalse);
      },
    );

    testWidgets('renders loading state and prevents interaction', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Loading CTA',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renders disabled state when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Disabled CTA',
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
        button.style?.backgroundColor?.resolve({
          WidgetState.disabled,
        }),
        AppPrimaryColors.shade100,
      );
    });

    testWidgets('renders leading icon alongside text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'With Icon',
              icon: const Icon(Icons.check),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });
  });
}
