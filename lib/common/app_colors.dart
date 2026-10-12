// ignore_for_file: document_ignores, public_member_api_docs

import 'package:flutter/material.dart';

/// Application color palette based on the "Amie UI Kit" Design System.
///
/// Divided into 4 main groups:
/// 1. Primary (Emerald / Mint)
/// 2. Secondary (Peach / Coral)
/// 3. Neutral (Warm Sand / Beige)
/// 4. Grey (Grayscale)
abstract final class AppColors {
  // Base / Legacy
  static const Color baseColor = Color(0xFF212735);

  // ===========================================================================
  // 1. PRIMARY GROUP (Mint / Emerald)
  // ===========================================================================
  static const Color primary = primary500;
  static const Color primary50 = Color(0xFFF1FCF8);
  static const Color primary100 = Color(0xFFD8F7EB);
  static const Color primary200 = Color(0xFFB2EFD7);
  static const Color primary300 = Color(0xFF87E6C1);
  static const Color primary400 = Color(0xFF5BD7AB);
  static const Color primary500 = Color(0xFF4AD3A2);
  static const Color primary600 = Color(0xFF34B988);
  static const Color primary700 = Color(0xFF28946D);
  static const Color primary800 = Color(0xFF217558);
  static const Color primary900 = Color(0xFF1D6049);

  // ===========================================================================
  // 2. SECONDARY GROUP (Peach / Coral)
  // ===========================================================================
  static const Color secondary = secondary500;
  static const Color secondary50 = Color(0xFFFFF5F0);
  static const Color secondary100 = Color(0xFFFFE1D1);
  static const Color secondary200 = Color(0xFFFFD3BA);
  static const Color secondary300 = Color(0xFFFFBF9B);
  static const Color secondary400 = Color(0xFFFFB288);
  static const Color secondary500 = Color(0xFFFF9F6A);
  static const Color secondary600 = Color(0xFFE89160);
  static const Color secondary700 = Color(0xFFB5714B);
  static const Color secondary800 = Color(0xFF8C573A);
  static const Color secondary900 = Color(0xFF6B432D);

  // ===========================================================================
  // 3. NEUTRAL GROUP (Warm Sand / Beige)
  // ===========================================================================
  static const Color neutral = neutral500;
  static const Color neutral50 = Color(0xFFFEFEFE);
  static const Color neutral100 = Color(0xFFFDFCFA);
  static const Color neutral200 = Color(0xFFFCFBF8);
  static const Color neutral300 = Color(0xFFFBF9F5);
  static const Color neutral400 = Color(0xFFFAF8F3);
  static const Color neutral500 = Color(0xFFF9F6F0);
  static const Color neutral600 = Color(0xFFE3E0DA);
  static const Color neutral700 = Color(0xFFB1AFAA);
  static const Color neutral800 = Color(0xFF898784);
  static const Color neutral900 = Color(0xFF696765);

  // ===========================================================================
  // 4. GREY GROUP (Grayscale)
  // ===========================================================================
  static const Color grey = grey500;
  static const Color grey50 = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFFAFAFA);
  static const Color grey200 = Color(0xFFF6F6F6);
  static const Color grey300 = Color(0xFFF2F2F2);
  static const Color grey400 = Color(0xFFEDEDED);
  static const Color grey500 = Color(0xFFE8E8E8);
  static const Color grey600 = Color(0xFF9A9A9A);
  static const Color grey700 = Color(0xFF6D6D6D);
  static const Color grey800 = Color(0xFF5B5B5B);
  static const Color grey900 = Color(0xFF414141);
  static const Color grey950 = Color(0xFF3A3A3A);
  static const Color grey1000 = Color(0xFF313131);
  static const Color grey1050 = Color(0xFF1F1F1F);
}

/// Dedicated subgroup for primary shades (Primary / Mint).
abstract final class AppPrimaryColors {
  static const Color shade50 = AppColors.primary50;
  static const Color shade100 = AppColors.primary100;
  static const Color shade200 = AppColors.primary200;
  static const Color shade300 = AppColors.primary300;
  static const Color shade400 = AppColors.primary400;
  static const Color shade500 = AppColors.primary500;
  static const Color shade600 = AppColors.primary600;
  static const Color shade700 = AppColors.primary700;
  static const Color shade800 = AppColors.primary800;
  static const Color shade900 = AppColors.primary900;
}

/// Dedicated subgroup for secondary shades (Secondary / Peach).
abstract final class AppSecondaryColors {
  static const Color shade50 = AppColors.secondary50;
  static const Color shade100 = AppColors.secondary100;
  static const Color shade200 = AppColors.secondary200;
  static const Color shade300 = AppColors.secondary300;
  static const Color shade400 = AppColors.secondary400;
  static const Color shade500 = AppColors.secondary500;
  static const Color shade600 = AppColors.secondary600;
  static const Color shade700 = AppColors.secondary700;
  static const Color shade800 = AppColors.secondary800;
  static const Color shade900 = AppColors.secondary900;
}

/// Dedicated subgroup for neutral shades (Neutral / Sand).
abstract final class AppNeutralColors {
  static const Color shade50 = AppColors.neutral50;
  static const Color shade100 = AppColors.neutral100;
  static const Color shade200 = AppColors.neutral200;
  static const Color shade300 = AppColors.neutral300;
  static const Color shade400 = AppColors.neutral400;
  static const Color shade500 = AppColors.neutral500;
  static const Color shade600 = AppColors.neutral600;
  static const Color shade700 = AppColors.neutral700;
  static const Color shade800 = AppColors.neutral800;
  static const Color shade900 = AppColors.neutral900;
}

/// Dedicated subgroup for grey shades (Grey / Grayscale).
abstract final class AppGreyColors {
  static const Color shade50 = AppColors.grey50;
  static const Color shade100 = AppColors.grey100;
  static const Color shade200 = AppColors.grey200;
  static const Color shade300 = AppColors.grey300;
  static const Color shade400 = AppColors.grey400;
  static const Color shade500 = AppColors.grey500;
  static const Color shade600 = AppColors.grey600;
  static const Color shade700 = AppColors.grey700;
  static const Color shade800 = AppColors.grey800;
  static const Color shade900 = AppColors.grey900;
  static const Color shade950 = AppColors.grey950;
  static const Color shade1000 = AppColors.grey1000;
  static const Color shade1050 = AppColors.grey1050;
}
