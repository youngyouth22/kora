import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/common/app_colors.dart';

/// Central theme configurations.
abstract final class AppThemes {
  ///
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'ClashDisplay',
    scaffoldBackgroundColor: AppColors.scaffoldColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimaryColors.shade600,
      primary: AppPrimaryColors.shade600,
      onPrimary: AppColors.scaffoldColor,
      surface: AppColors.scaffoldColor,
      error: AppErrorColors.shade400,
    ),
    appBarTheme: AppBarTheme(
      leadingWidth: 24,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppGreyColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: AppGreyColors.shade600,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: AppGreyColors.shade800,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: const TextStyle(
        color: AppErrorColors.shade400,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppGreyColors.shade400,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppGreyColors.shade400,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppPrimaryColors.shade500,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppErrorColors.shade400,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppErrorColors.shade500,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppGreyColors.shade300,
        ),
      ),
    ),
    // dividerColor: AppColors.greyScale200,
    // dividerTheme: const DividerThemeData(color: AppColors.greyScale200),
    // appBarTheme: AppBarTheme(
    //   backgroundColor: AppColors.white,
    //   surfaceTintColor: AppColors.white,
    //   titleTextStyle: AppTypography.h4Bold.copyWith(
    //     color: AppColors.greyScale900),
    //   centerTitle: true,
    // elevation: 0,
    // systemOverlayStyle: const SystemUiOverlayStyle(
    //   systemNavigationBarColor: AppColors.white,
    //   statusBarColor: AppColors.white,
    //   systemNavigationBarIconBrightness: Brightness.dark,
    // ),
    // ),
  );

  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   fontFamily: "ClashDisplay",
  //   dividerColor: AppColors.dark3,
  //   scaffoldBackgroundColor: AppColors.dark1,
  //   appBarTheme: AppBarTheme(
  //     backgroundColor: AppColors.dark1,
  //     surfaceTintColor: AppColors.dark1,
  //     titleTextStyle: AppTypography.h4Bold.copyWith(color: AppColors.white),
  //     centerTitle: true,
  //     elevation: 0,
  //     systemOverlayStyle:
  //const SystemUiOverlayStyle(statusBarColor: AppColors.white),
  //   ),
  // );
}
