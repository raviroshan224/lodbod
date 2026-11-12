import 'package:material_ui/material_ui.dart';

/// LODBOD palette. Orange is the action colour in both modes; everything
/// else swaps between the light and dark sets below.
///
/// The palette is read through static getters so the hundreds of call sites
/// stay as they are. [brightness] is set by the app before it builds, and
/// the whole tree is rebuilt on a change, so a stale colour can't linger.
abstract final class AppColors {
  static Brightness brightness = Brightness.light;
  static bool get isDark => brightness == Brightness.dark;
  static _Palette get _p => isDark ? _dark : _light;

  /// Brand orange (kept exactly). White bold text on it meets WCAG AA.
  static const primary = Color(0xFFD9470F);
  static const primaryDark = Color(0xFFB83A09);

  static Color get primaryContainer => _p.primaryContainer;
  static Color get onPrimaryContainer => _p.onPrimaryContainer;
  static Color get primarySoft => _p.primarySoft;
  static Color get primaryBorder => _p.primaryBorder;
  static Color get onPrimarySoft => _p.onPrimarySoft;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceMuted => _p.surfaceMuted;
  static Color get surfaceContainer => _p.surfaceContainer;
  static Color get surfaceContainerHigh => _p.surfaceContainerHigh;
  static Color get border => _p.border;
  static Color get divider => _p.divider;

  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textMuted => _p.textMuted;

  static Color get error => _p.error;
  static Color get errorSoft => _p.errorSoft;
  static Color get success => _p.success;
  static Color get successSoft => _p.successSoft;
  static Color get info => _p.info;
  static Color get infoSoft => _p.infoSoft;
  static Color get warning => _p.warning;
  static Color get warningSoft => _p.warningSoft;
  static Color get violet => _p.violet;
  static Color get violetSoft => _p.violetSoft;
  static Color get teal => _p.teal;
  static Color get tealSoft => _p.tealSoft;

  static Color get skeleton => _p.skeleton;
  static Color get skeletonHighlight => _p.skeletonHighlight;

  /// Material 3 cards are flat (tonal contrast, no shadow); this is only
  /// for elements floating over a map or image.
  static List<BoxShadow> get shadow => _p.shadow;

  /// Warm neutrals: screens sit on [background], content on [surface].
  static const _light = _Palette(
    primaryContainer: Color(0xFFFFDBD0),
    onPrimaryContainer: Color(0xFF723521),
    primarySoft: Color(0xFFFFEDE7),
    primaryBorder: Color(0xFFF5C4B3),
    onPrimarySoft: Color(0xFF8F2C05),
    background: Color(0xFFF8F2EF),
    surface: Colors.white,
    surfaceMuted: Color(0xFFFBF7F5),
    surfaceContainer: Color(0xFFF3EBE7),
    surfaceContainerHigh: Color(0xFFECE2DD),
    border: Color(0xFFE6DAD5),
    divider: Color(0xFFF1E9E5),
    textPrimary: Color(0xFF231917),
    textSecondary: Color(0xFF53433F),
    textMuted: Color(0xFF85736E),
    error: Color(0xFFBA1A1A),
    errorSoft: Color(0xFFFFEDEA),
    success: Color(0xFF146C2E),
    successSoft: Color(0xFFE3F4E6),
    info: Color(0xFF1B5FC2),
    infoSoft: Color(0xFFE6EEFC),
    warning: Color(0xFF8A5100),
    warningSoft: Color(0xFFFFF0D9),
    violet: Color(0xFF6A3FC4),
    violetSoft: Color(0xFFF0EAFC),
    teal: Color(0xFF006A62),
    tealSoft: Color(0xFFDDF3EF),
    skeleton: Color(0xFFEFE6E2),
    skeletonHighlight: Color(0xFFF8F2EF),
    shadow: [
      BoxShadow(color: Color(0x14231917), blurRadius: 16, offset: Offset(0, 6)),
      BoxShadow(color: Color(0x0A231917), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );

  /// Same warm hue family, inverted: the tints that were "soft" fills become
  /// deep tones, and the saturated status colours lighten for contrast on
  /// dark surfaces.
  static const _dark = _Palette(
    primaryContainer: Color(0xFF5C2A18),
    onPrimaryContainer: Color(0xFFFFD9CB),
    primarySoft: Color(0xFF3B2219),
    primaryBorder: Color(0xFF6E3B28),
    onPrimarySoft: Color(0xFFFFB79F),
    background: Color(0xFF15110F),
    surface: Color(0xFF211B18),
    surfaceMuted: Color(0xFF1B1613),
    surfaceContainer: Color(0xFF2B2420),
    surfaceContainerHigh: Color(0xFF362D28),
    border: Color(0xFF3E342F),
    divider: Color(0xFF2E2622),
    textPrimary: Color(0xFFF4EDE9),
    textSecondary: Color(0xFFCBBFB9),
    textMuted: Color(0xFF93867F),
    error: Color(0xFFFFB4AB),
    errorSoft: Color(0xFF4A1F1B),
    success: Color(0xFF8ED8A6),
    successSoft: Color(0xFF1D3A28),
    info: Color(0xFFA6C8FF),
    infoSoft: Color(0xFF1F2E4A),
    warning: Color(0xFFF4BE74),
    warningSoft: Color(0xFF3E2F13),
    violet: Color(0xFFCDB8FF),
    violetSoft: Color(0xFF2F2548),
    teal: Color(0xFF86DBCF),
    tealSoft: Color(0xFF183633),
    skeleton: Color(0xFF2B2420),
    skeletonHighlight: Color(0xFF362D28),
    shadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
      BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );
}

class _Palette {
  const _Palette({
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primarySoft,
    required this.primaryBorder,
    required this.onPrimarySoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.error,
    required this.errorSoft,
    required this.success,
    required this.successSoft,
    required this.info,
    required this.infoSoft,
    required this.warning,
    required this.warningSoft,
    required this.violet,
    required this.violetSoft,
    required this.teal,
    required this.tealSoft,
    required this.skeleton,
    required this.skeletonHighlight,
    required this.shadow,
  });

  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primarySoft;
  final Color primaryBorder;
  final Color onPrimarySoft;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color error;
  final Color errorSoft;
  final Color success;
  final Color successSoft;
  final Color info;
  final Color infoSoft;
  final Color warning;
  final Color warningSoft;
  final Color violet;
  final Color violetSoft;
  final Color teal;
  final Color tealSoft;
  final Color skeleton;
  final Color skeletonHighlight;
  final List<BoxShadow> shadow;
}
