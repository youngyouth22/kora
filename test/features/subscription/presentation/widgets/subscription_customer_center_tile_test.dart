import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/subscription/presentation/widgets/subscription_customer_center_tile.dart';

void main() {
  group('SubscriptionCustomerCenterTile', () {
    testWidgets('renders title, subtitle, and accessible Semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubscriptionCustomerCenterTile(),
          ),
        ),
      );

      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(
        find.text('View plan, billing, restore, or cancel'),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsOneWidget);
      expect(
        find.bySemanticsLabel('Manage Kora Pro Subscription'),
        findsOneWidget,
      );
    });
  });
}
