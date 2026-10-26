import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/widgets/secondary_button.dart';

void main() {
  group('SecondaryButton Widget Tests', () {
    testWidgets(
      'renders OutlinedButton with default border, text color, and '
      'tap response',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Secondary Action',
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Secondary Action'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);

        final outlinedButton = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );

        // Verify default side is 1px AppPrimaryColors.shade600
        final borderSide = outlinedButton.style?.side?.resolve({});
        expect(borderSide?.color, AppPrimaryColors.shade600);

        // Verify text color
        final textWidget = tester.widget<Text>(find.text('Secondary Action'));
        expect(textWidget.style?.color, AppPrimaryColors.shade600);

        // Verify default semantics
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Secondary Action' &&
                (widget.properties.button ?? false) &&
                (widget.properties.enabled ?? false),
          ),
          findsOneWidget,
        );

        // Tap
        await tester.tap(find.byType(SecondaryButton));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets('provides accessible Semantics with custom semanticLabel', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              text: 'Skip',
              semanticLabel: 'Skip this onboarding step',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Skip this onboarding step' &&
              (widget.properties.button ?? false) &&
              (widget.properties.enabled ?? false),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'when isDisabled is true, removes border, applies shade100, preserves '
      'text color, disables Semantics, and blocks clicks',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Disabled Action',
                isDisabled: true,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );

        // Tap interaction blocked
        expect(button.onPressed, isNull);

        // Border outline is removed
        expect(
          button.style?.side?.resolve({WidgetState.disabled}),
          BorderSide.none,
        );

        // Background becomes shade100
        expect(
          button.style?.backgroundColor?.resolve({
            WidgetState.disabled,
          }),
          AppPrimaryColors.shade100,
        );

        // Text color preserved
        expect(
          button.style?.foregroundColor?.resolve({
            WidgetState.disabled,
          }),
          AppPrimaryColors.shade600,
        );

        // Semantics reflects disabled
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Disabled Action' &&
                !(widget.properties.enabled ?? true),
          ),
          findsOneWidget,
        );

        // Tap does not trigger callback
        await tester.tap(find.byType(SecondaryButton), warnIfMissed: false);
        await tester.pump();
        expect(tapped, isFalse);
      },
    );

    testWidgets(
      'when onPressed is null, sets disabled background and disables Semantics',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Null Callback',
              ),
            ),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.onPressed, isNull);
        expect(
          button.style?.backgroundColor?.resolve({
            WidgetState.disabled,
          }),
          AppPrimaryColors.shade100,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Null Callback' &&
                !(widget.properties.enabled ?? true),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders loading state and disables Semantics and interaction',
      (
        tester,
      ) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Loading Action',
                isLoading: true,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.onPressed, isNull);

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Loading Action' &&
                !(widget.properties.enabled ?? true),
          ),
          findsOneWidget,
        );

        await tester.tap(find.byType(SecondaryButton), warnIfMissed: false);
        await tester.pump();
        expect(tapped, isFalse);
      },
    );

    testWidgets(
      'respects custom styling (backgroundColor, side, textColor, textStyle)',
      (tester) async {
        const customSide = BorderSide(
          color: AppPrimaryColors.shade900,
          width: 2,
        );
        const customTextStyle = TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Custom Style',
                backgroundColor: AppNeutralColors.shade200,
                textColor: AppPrimaryColors.shade900,
                side: customSide,
                textStyle: customTextStyle,
                borderRadius: 16,
                height: 52,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );

        expect(
          button.style?.backgroundColor?.resolve({}),
          AppNeutralColors.shade200,
        );
        expect(button.style?.side?.resolve({}), customSide);
        expect(
          button.style?.foregroundColor?.resolve({}),
          AppPrimaryColors.shade900,
        );

        final textWidget = tester.widget<Text>(find.text('Custom Style'));
        expect(textWidget.style, customTextStyle);

        final sizedBox = tester.widget<SizedBox>(
          find
              .descendant(
                of: find.byType(SecondaryButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(sizedBox.height, 52);
      },
    );

    testWidgets('renders leading icon alongside text with alignment support', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              text: 'Next Step',
              icon: const Icon(Icons.arrow_forward),
              iconAlignment: IconAlignment.end,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);

      final iconOffset = tester.getTopLeft(find.byIcon(Icons.arrow_forward));
      final textOffset = tester.getTopLeft(find.text('Next Step'));
      // With iconAlignment: IconAlignment.end, the text is positioned before
      // (to the left of) the icon
      expect(textOffset.dx, lessThan(iconOffset.dx));
    });
  });
}
