import 'package:material_ui/material_ui.dart';

/// LODBOD brand palette. Orange is the action colour; surfaces stay white on
/// a light neutral background so content, not chrome, carries the hierarchy.
abstract final class AppColors {
  /// Brand orange. White bold text on it meets WCAG AA (≈4.5:1).
  static const primary = Color(0xFFD9470F);
  static const primaryDark = Color(0xFFB83A09);
  static const primarySoft = Color(0xFFFFF1EA);
  static const primaryBorder = Color(0xFFF9D2C0);
  static const onPrimarySoft = Color(0xFF8F2C05);

  static const background = Color(0xFFF5F5F7);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF9F9FB);
  static const border = Color(0xFFE9E9EE);
  static const divider = Color(0xFFF0F0F3);

  static const textPrimary = Color(0xFF121216);
  static const textSecondary = Color(0xFF5D5D69);
  static const textMuted = Color(0xFF8C8C98);

  static const error = Color(0xFFC62828);
  static const errorSoft = Color(0xFFFDEDED);
  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFE8F6ED);
  static const info = Color(0xFF1D4ED8);
  static const infoSoft = Color(0xFFEAF0FE);
  static const warning = Color(0xFF9A5B00);
  static const warningSoft = Color(0xFFFFF5DD);
  static const violet = Color(0xFF6D28D9);
  static const violetSoft = Color(0xFFF1ECFD);
  static const teal = Color(0xFF0F766E);
  static const tealSoft = Color(0xFFE2F5F2);

  static const skeleton = Color(0xFFECECF0);
  static const skeletonHighlight = Color(0xFFF7F7F9);

  /// Very soft elevation used on cards and floating controls.
  static const shadow = [
    BoxShadow(color: Color(0x0A101828), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x05101828), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
