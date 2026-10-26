import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/profile/presentation/widgets/setting_tile.dart';

void main() {
  group('SettingTile', () {
    testWidgets('renders title and triggers onTap when pressed', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingTile(
              icon: Icons.track_changes_rounded,
              title: 'Routine Preferences',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Routine Preferences'), findsOneWidget);
      expect(find.byIcon(Icons.track_changes_rounded), findsOneWidget);

      await tester.tap(find.text('Routine Preferences'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders custom leading and subtitle if provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingTile(
              title: 'Custom Tile',
              subtitle: 'Helpful subtitle',
              leading: const Icon(Icons.star),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Custom Tile'), findsOneWidget);
      expect(find.text('Helpful subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
