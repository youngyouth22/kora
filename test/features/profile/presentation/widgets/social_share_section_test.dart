import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';
import 'package:kora/features/profile/presentation/widgets/setting_tile.dart';
import 'package:kora/features/profile/presentation/widgets/social_share_section.dart';

void main() {
  group('SocialShareSection', () {
    testWidgets(
      'renders SettingSection and default social items and share tile',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SocialShareSection(
                title: 'Get involved',
              ),
            ),
          ),
        );

        expect(find.byType(SettingSection), findsOneWidget);
        expect(find.text('Instagram'), findsOneWidget);
        expect(find.text('Tiktok'), findsOneWidget);
        expect(find.text('X'), findsOneWidget);
        expect(find.text('Snapchat'), findsOneWidget);
        expect(find.text('Share Kora'), findsOneWidget);
        expect(find.byType(SettingTile), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
      },
    );

    testWidgets('renders custom title and custom shareTitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialShareSection(
              title: 'Get Involved',
              shareTitle: 'Share Amie',
            ),
          ),
        ),
      );

      expect(find.text('Get Involved'), findsOneWidget);
      expect(find.text('Share Amie'), findsOneWidget);
    });

    testWidgets(
      'triggers callbacks when social items and share tile are tapped',
      (tester) async {
        var instagramTapped = false;
        var tikTokTapped = false;
        var xTapped = false;
        var snapchatTapped = false;
        var shareTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialShareSection(
                title: 'Get involved',
                onInstagramTap: () => instagramTapped = true,
                onTikTokTap: () => tikTokTapped = true,
                onXTap: () => xTapped = true,
                onSnapchatTap: () => snapchatTapped = true,
                onShareTap: () => shareTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Instagram'));
        expect(instagramTapped, isTrue);

        await tester.tap(find.text('Tiktok'));
        expect(tikTokTapped, isTrue);

        await tester.tap(find.text('X'));
        expect(xTapped, isTrue);

        await tester.tap(find.text('Snapchat'));
        expect(snapchatTapped, isTrue);

        await tester.tap(find.text('Share Kora'));
        expect(shareTapped, isTrue);
      },
    );

    testWidgets('supports custom items list', (tester) async {
      var customTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialShareSection(
              title: 'Get involved',
              items: [
                SocialShareItem(
                  label: 'Custom Platform',
                  iconPath: ImageResources.instagramIcon,
                  onTap: () => customTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom Platform'), findsOneWidget);
      expect(find.text('Instagram'), findsNothing);

      await tester.tap(find.text('Custom Platform'));
      expect(customTapped, isTrue);
    });
  });
}
