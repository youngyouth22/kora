import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

void main() {
  group('SettingSection', () {
    testWidgets('renders title and children inside KoraCard', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingSection(
              title: 'Personalization',
              children: [
                Text('Child Item 1'),
                Text('Child Item 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Personalization'), findsOneWidget);
      expect(find.byType(KoraCard), findsOneWidget);
      expect(find.text('Child Item 1'), findsOneWidget);
      expect(find.text('Child Item 2'), findsOneWidget);
    });

    testWidgets('renders title and single child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingSection(
              title: 'Account & Settings',
              child: Text('Single Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Account & Settings'), findsOneWidget);
      expect(find.byType(KoraCard), findsOneWidget);
      expect(find.text('Single Child Content'), findsOneWidget);
    });

    testWidgets('applies custom title style and card padding', (tester) async {
      const customStyle = TextStyle(fontSize: 22, color: Colors.blue);
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingSection(
              title: 'Custom Header',
              titleTextStyle: customStyle,
              cardPadding: customPadding,
              child: Text('Custom Content'),
            ),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('Custom Header'));
      expect(titleWidget.style?.fontSize, 22);

      final cardWidget = tester.widget<KoraCard>(find.byType(KoraCard));
      expect(cardWidget.padding, customPadding);
    });

    testWidgets('renders card without title when title is omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingSection(
              title: 'Get involved',
              child: Text('Content without title'),
            ),
          ),
        ),
      );

      expect(find.byType(KoraCard), findsOneWidget);
      expect(find.text('Content without title'), findsOneWidget);
    });
  });
}
