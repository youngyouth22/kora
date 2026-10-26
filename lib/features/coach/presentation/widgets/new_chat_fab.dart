// import 'package:flutter/material.dart';
// import 'package:kora/common/app_colors.dart';
// import 'package:kora/common/app_typography.dart';

// /// A reusable primary call-to-action button adhering to the Kora
// class NewChatFab extends StatelessWidget {

//   /// * [onPressed] is executed on tap. When null, the button is disabled.
//   const NewChatFab({
//     required this.text,
//     super.key,
//     this.onPressed,
//   });

//   /// The callback to execute when the button is pressed.
//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     final effectivelyDisabled =
//         isDisabled || (onPressed == null && !isLoading);
//     final hasSolidBackground = backgroundColor != null;
//     final effectiveGradient = (hasSolidBackground || effectivelyDisabled)
//         ? null
//         : (gradient ?? AppGradients.primary);
//     final effectiveBackgroundColor =
//         backgroundColor ?? AppPrimaryColors.shade600;
//     final effectiveTextColor = textColor ?? AppGreyColors.white;
//     final effectiveSide = effectivelyDisabled
//         ? null
//         : side ?? const BorderSide(color: AppPrimaryColors.shade500);

//     Widget button = ElevatedButton.icon(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: effectiveGradient != null
//             ? Colors.transparent
//             : effectiveBackgroundColor,
//         foregroundColor: effectiveTextColor,
//         disabledBackgroundColor: AppPrimaryColors.shade100,
//         disabledForegroundColor: effectiveTextColor,
//         shadowColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         side: effectiveSide,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(100),
//           side: effectiveSide ?? BorderSide.none,
//         ),
//         elevation: 0,
//       ),
//       icon: icon,
//       iconAlignment: iconAlignment,
//       label: Text(
//               text,
//               style:
//                   textStyle ??
//                   AppTypography.bodyXlSemiBold.copyWith(
//                     color: effectiveTextColor,
//                   ),
//             ),
//     );

//     if (effectiveGradient != null) {
//       button = DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: effectiveGradient,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//         child: button,
//       );
//     }

//     return Semantics(
//       container: true,
//       button: true,
//       enabled: !effectivelyDisabled && !isLoading,
//       label: semanticLabel ?? text,
//       child: SizedBox(
//         width: width,
//         height: height,
//         child: button,
//       ),
//     );
//   }
// }
