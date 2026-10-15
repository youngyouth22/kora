import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/presentation/widgets/top_bar_controls.dart';

void main() {
  group('TopBarControls Widget Tests', () {
    testWidgets('renders controls and responds to callbacks', (tester) async {
      var cancelTapped = false;
      var helpTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBarControls(
              isLightOk: true,
              isAllValid: false,
              onCancel: () => cancelTapped = true,
              onHelp: () => helpTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.byIcon(Icons.help_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(cancelTapped, isTrue);

      await tester.tap(find.byIcon(Icons.help_rounded));
      expect(helpTapped, isTrue);
    });

    testWidgets('displays LOW when isLightOk is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBarControls(
              isLightOk: false,
              isAllValid: false,
              onCancel: () {},
              onHelp: () {},
            ),
          ),
        ),
      );

      expect(find.text('LOW'), findsOneWidget);
    });
  });
}
