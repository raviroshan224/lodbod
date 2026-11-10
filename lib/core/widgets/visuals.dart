import 'package:material_ui/material_ui.dart';

/// Colours and icon for a status pill. Features map their own statuses to
/// one of these (e.g. `shipmentStatusStyle`, `bidStatusStyle`). Status is
/// always shown with text as well as colour, so it never relies on colour
/// alone.
class StatusStyle {
  const StatusStyle(this.foreground, this.background, this.icon);
  final Color foreground;
  final Color background;
  final IconData icon;
}
