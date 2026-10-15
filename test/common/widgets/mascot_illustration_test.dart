import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';

final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(_transparentPng);
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    final data = const StandardMessageCodec().encodeMessage(
      <String, dynamic>{
        MascotPose.wave.path: <dynamic>[],
        MascotPose.success.path: <dynamic>[],
      },
    )!;
    return parser(data);
  }
}

void main() {
  group('MascotIllustration Widget Tests', () {
    testWidgets('renders MascotIllustration with default size and fit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: _FakeAssetBundle(),
            child: const Scaffold(
              body: MascotIllustration(pose: MascotPose.wave),
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.width, 120);
      expect(imageWidget.height, 120);
      expect(imageWidget.fit, BoxFit.contain);
      expect(imageWidget.gaplessPlayback, isTrue);

      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, MascotPose.wave.path);
    });

    testWidgets('renders MascotIllustration with custom size and fit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: _FakeAssetBundle(),
            child: const Scaffold(
              body: MascotIllustration(
                pose: MascotPose.success,
                size: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.width, 200);
      expect(imageWidget.height, 200);
      expect(imageWidget.fit, BoxFit.cover);

      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, MascotPose.success.path);
    });
  });
}
