import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      expect(find.widgetWithText(SecondaryButton, 'Sign out'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Tiktok'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Snapchat'), findsOneWidget);
      expect(find.text('Share Kora'), findsOneWidget);
    });
  });
}
