import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';

void main() {
  group('AppColors', () {
    test('defines main palette groups and base colors', () {
      expect(AppColors.baseColor, const Color(0xFF212735));
      expect(AppColors.scaffoldColor, const Color(0xFFF9F6F0));
      expect(AppColors.primary, AppColors.primary500);
      expect(AppColors.secondary, AppColors.secondary500);
      expect(AppColors.neutral, AppColors.neutral500);
      expect(AppColors.grey, AppColors.grey500);
      expect(AppColors.error, AppColors.error400);
    });

    test('defines error scale colors correctly', () {
      expect(AppColors.error25, const Color(0xFFFFFBFA));
      expect(AppColors.error50, const Color(0xFFFEF3F2));
      expect(AppColors.error100, const Color(0xFFFEE4E2));
      expect(AppColors.error200, const Color(0xFFFECDCA));
      expect(AppColors.error300, const Color(0xFFFDA29B));
      expect(AppColors.error400, const Color(0xFFF04438));
      expect(AppColors.error500, const Color(0xFFD92D20));
      expect(AppColors.error600, const Color(0xFFB42318));
      expect(AppColors.error700, const Color(0xFF912018));
      expect(AppColors.error800, const Color(0xFF7A271A));
    });
  });

  group('AppErrorColors', () {
    test('exposes all error shades matching AppColors', () {
      expect(AppErrorColors.shade25, AppColors.error25);
      expect(AppErrorColors.shade50, AppColors.error50);
      expect(AppErrorColors.shade100, AppColors.error100);
      expect(AppErrorColors.shade200, AppColors.error200);
      expect(AppErrorColors.shade300, AppColors.error300);
      expect(AppErrorColors.shade400, AppColors.error400);
      expect(AppErrorColors.shade500, AppColors.error500);
      expect(AppErrorColors.shade600, AppColors.error600);
      expect(AppErrorColors.shade700, AppColors.error700);
      expect(AppErrorColors.shade800, AppColors.error800);
    });
  });

  group('AppGradients', () {
    test('defines default primary linear gradient', () {
      expect(
        AppGradients.primary.colors,
        equals([
          AppPrimaryColors.shade600,
          AppPrimaryColors.shade600,
        ]),
      );
      expect(AppGradients.primary.stops, equals([0.5, 1]));
      expect(AppGradients.primary.begin, Alignment.topCenter);
      expect(AppGradients.primary.end, Alignment.bottomCenter);
    });
  });

  group('AppSkinToneColors', () {
    test('defines all 6 Fitzpatrick skin tone swatch colors', () {
      expect(AppSkinToneColors.typeI, const Color(0xFFF9EAE1));
      expect(AppSkinToneColors.typeII, const Color(0xFFF1D7C2));
      expect(AppSkinToneColors.typeIII, const Color(0xFFDCB293));
      expect(AppSkinToneColors.typeIV, const Color(0xFFB88258));
      expect(AppSkinToneColors.typeV, const Color(0xFF885635));
      expect(AppSkinToneColors.typeVI, const Color(0xFF4C2B1C));
      expect(AppSkinToneColors.veryFair, AppSkinToneColors.typeI);
      expect(AppSkinToneColors.fair, AppSkinToneColors.typeII);
      expect(AppSkinToneColors.medium, AppSkinToneColors.typeIII);
      expect(AppSkinToneColors.olive, AppSkinToneColors.typeIV);
      expect(AppSkinToneColors.brown, AppSkinToneColors.typeV);
      expect(AppSkinToneColors.deep, AppSkinToneColors.typeVI);
    });
  });

  group('AppBadgeColors', () {
    test('defines question badge background and icon colors', () {
      expect(AppBadgeColors.savingsBg, const Color(0xFFFFEBF0));
      expect(AppBadgeColors.savingsIcon, const Color(0xFFF0447C));
      expect(AppBadgeColors.valueBg, const Color(0xFFE2F9EF));
      expect(AppBadgeColors.valueIcon, const Color(0xFF28946D));
      expect(AppBadgeColors.innovativeBg, const Color(0xFFE8EDFF));
      expect(AppBadgeColors.innovativeIcon, const Color(0xFF536DFE));
      expect(AppBadgeColors.ultimateBg, const Color(0xFFE0F5EE));
      expect(AppBadgeColors.ultimateIcon, const Color(0xFF1D6049));
    });
  });
}
