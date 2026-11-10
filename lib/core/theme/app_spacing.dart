import 'package:material_ui/material_ui.dart';

/// Spacing and radius scale used across the app.
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal page gutter.
  static const double page = 16;
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 28;

  /// Material 3 Expressive shapes: large rounded cards, pill buttons.
  static final card = BorderRadius.circular(xl);
  static final input = BorderRadius.circular(lg);
  static final button = BorderRadius.circular(999);
  static final chip = BorderRadius.circular(999);
  static const sheet = BorderRadius.vertical(top: Radius.circular(xxl));
}

/// Shorthand spacers.
abstract final class Space {
  static const v2 = SizedBox(height: 2);
  static const v4 = SizedBox(height: 4);
  static const v6 = SizedBox(height: 6);
  static const v8 = SizedBox(height: 8);
  static const v12 = SizedBox(height: 12);
  static const v16 = SizedBox(height: 16);
  static const v20 = SizedBox(height: 20);
  static const v24 = SizedBox(height: 24);
  static const v32 = SizedBox(height: 32);
  static const h4 = SizedBox(width: 4);
  static const h6 = SizedBox(width: 6);
  static const h8 = SizedBox(width: 8);
  static const h10 = SizedBox(width: 10);
  static const h12 = SizedBox(width: 12);
  static const h16 = SizedBox(width: 16);
}
