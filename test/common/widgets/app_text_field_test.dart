import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_themes.dart';
import 'package:kora/common/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField renders label, hint, and accepts typing', (
    tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.lightTheme,
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            hintText: 'Enter email',
            labelText: 'Email',
          ),
        ),
      ),
    );

    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'test@kora.app');
    expect(controller.text, 'test@kora.app');
  });

  testWidgets(
    'AppTextField toggles password visibility when isPassword is true',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.lightTheme,
          home: const Scaffold(
            body: AppTextField(
              isPassword: true,
              hintText: 'Password',
            ),
          ),
        ),
      );

      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(iconButton);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    },
  );
}
