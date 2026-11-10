import 'package:material_ui/material_ui.dart';

/// LODBOD brand palette. Orange is the action colour; surfaces stay white on
/// a light neutral background so content, not chrome, carries the hierarchy.
abstract final class AppColors {
  /// Brand orange (kept exactly). White bold text on it meets WCAG AA.
  static const primary = Color(0xFFD9470F);
  static const primaryDark = Color(0xFFB83A09);

  /// Material 3 tonal companions generated from the brand orange.
  static const primaryContainer = Color(0xFFFFDBD0);
  static const onPrimaryContainer = Color(0xFF723521);
  static const primarySoft = Color(0xFFFFEDE7);
  static const primaryBorder = Color(0xFFF5C4B3);
  static const onPrimarySoft = Color(0xFF8F2C05);

  /// Warm neutral surfaces (M3 surface containers from the same seed):
  /// screens sit on [background], content on white [surface].
  static const background = Color(0xFFF8F2EF);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFFBF7F5);
  static const surfaceContainer = Color(0xFFF3EBE7);
  static const surfaceContainerHigh = Color(0xFFECE2DD);
  static const border = Color(0xFFE6DAD5);
  static const divider = Color(0xFFF1E9E5);

  static const textPrimary = Color(0xFF231917);
  static const textSecondary = Color(0xFF53433F);
  static const textMuted = Color(0xFF85736E);

  static const error = Color(0xFFBA1A1A);
  static const errorSoft = Color(0xFFFFEDEA);
  static const success = Color(0xFF146C2E);
  static const successSoft = Color(0xFFE3F4E6);
  static const info = Color(0xFF1B5FC2);
  static const infoSoft = Color(0xFFE6EEFC);
  static const warning = Color(0xFF8A5100);
  static const warningSoft = Color(0xFFFFF0D9);
  static const violet = Color(0xFF6A3FC4);
  static const violetSoft = Color(0xFFF0EAFC);
  static const teal = Color(0xFF006A62);
  static const tealSoft = Color(0xFFDDF3EF);

  static const skeleton = Color(0xFFEFE6E2);
  static const skeletonHighlight = Color(0xFFF8F2EF);

  /// Material 3 cards are flat (tonal contrast, no shadow); this is only
  /// for elements floating over a map or image.
  static const shadow = [
    BoxShadow(color: Color(0x14231917), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0A231917), blurRadius: 3, offset: Offset(0, 1)),
  ];
}
