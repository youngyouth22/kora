import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/features/profile/presentation/pages/profile_page.dart';
import 'package:kora/features/profile/presentation/widgets/social_share_section.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('renders profile preview, sections, and SocialShareSection', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(SocialShareSection), findsOneWidget);
      expect(find.text('Personalization'), findsOneWidget);
      expect(find.text('Routine Preferences'), findsOneWidget);
      expect(find.text('Skin profile & quiz'), findsOneWidget);
      expect(find.widgetWithText(SecondaryButton, 'Sign out'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Tiktok'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Snapchat'), findsOneWidget);
      expect(find.text('Share Kora'), findsOneWidget);
    });

    testWidgets(
      'displays guest badge, save progress banner and link CTA when guest',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ProfilePage(),
          ),
        );
        await tester.pump();

        // Guest badge
        expect(find.text('Guest mode'), findsOneWidget);

        // Guest backup banner
        expect(find.text('Save your skin progress'), findsOneWidget);
        expect(
          find.text(
            'Sign in to sync your scans, custom routine, '
            'and progress safely to your account.',
          ),
          findsOneWidget,
        );

        // Sign in & save data CTA
        expect(
          find.widgetWithText(PrimaryButton, 'Sign in & save data'),
          findsOneWidget,
        );

        // Account & Settings link tile
        expect(find.text('Link account & sync'), findsOneWidget);
        expect(find.text('Save guest data to cloud'), findsOneWidget);
      },
    );
  });
}
