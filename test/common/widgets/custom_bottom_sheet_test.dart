import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';

void main() {
  group('CustomBottomSheet Widget Tests', () {
    testWidgets('renders content and wraps intrinsic height without title', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        content: const SizedBox(
                          key: Key('test_content'),
                          height: 120,
                          child: Text('Sheet Content'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Content should be visible
      expect(find.byKey(const Key('test_content')), findsOneWidget);
      expect(find.text('Sheet Content'), findsOneWidget);

      // Verify no divider is present when title is null
      expect(find.byType(Divider), findsNothing);

      // Drag handle should be visible by default
      expect(find.bySemanticsLabel('Drag handle'), findsOneWidget);

      // Container should wrap content and NOT occupy full screen
      final contentFinder = find.byKey(const Key('test_content'));
      final contentBox = tester.renderObject<RenderBox>(contentFinder);
      expect(contentBox.size.height, equals(120));

      final sheetContentFinder = find.byType(CustomBottomSheetContent);
      final sheetBox = tester.renderObject<RenderBox>(sheetContentFinder);
      // Sheet should be much smaller than screen height (600)
      expect(sheetBox.size.height, lessThan(300));
    });

    testWidgets('renders title and divider when title is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        title: 'My Custom Title',
                        content: const Text('Body Details'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('My Custom Title'), findsOneWidget);
      expect(find.text('Body Details'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('respects showDragHandle false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        showDragHandle: false,
                        content: const Text('No Handle Content'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('No Handle Content'), findsOneWidget);
      expect(find.bySemanticsLabel('Drag handle'), findsNothing);
    });

    testWidgets('renders BackdropFilter when useBlur is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        content: const Text('Blurred Sheet'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('does not render BackdropFilter when useBlur is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        useBlur: false,
                        content: const Text('Non Blurred Sheet'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('dismisses on barrier tap when isDismissible is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        content: const Text('Dismissible Content'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Content'), findsOneWidget);

      // Tap outside top area
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Content'), findsNothing);
    });

    testWidgets('renders with custom colors and contentPadding', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    unawaited(
                      showCustomModalBottomSheet<void>(
                        context: context,
                        backgroundColor: AppColors.neutral200,
                        dragHandleColor: AppPrimaryColors.shade600,
                        contentPadding: const EdgeInsets.all(32),
                        title: 'Themed Title',
                        titleColor: AppPrimaryColors.shade800,
                        content: const Text('Styled Content'),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Themed Title'));
      expect(text.style?.color, equals(AppPrimaryColors.shade800));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomSheetContent),
          matching: find.byType(Container).first,
        ),
      );
      final boxDecoration = container.decoration as BoxDecoration?;
      expect(boxDecoration?.color, equals(AppColors.neutral200));
    });

    testWidgets('CustomBottomSheetContent supports non-scrollable mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomBottomSheetContent(
              isScrollable: false,
              content: Text('Direct Column Content'),
            ),
          ),
        ),
      );

      expect(find.text('Direct Column Content'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('CustomBottomSheetContent supports explicit fixed height', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomBottomSheetContent(
              height: 500,
              isScrollable: false,
              content: Text('Expanded Fixed Content'),
            ),
          ),
        ),
      );

      expect(find.text('Expanded Fixed Content'), findsOneWidget);
      final containerFinder = find.byType(Container).first;
      final containerBox = tester.renderObject<RenderBox>(containerFinder);
      expect(containerBox.size.height, equals(500));
    });
  });
}
