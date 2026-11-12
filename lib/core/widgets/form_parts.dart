import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Label above a field. Required fields get an orange asterisk; optional
/// ones say so, so it's always clear what must be filled in.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.isRequired = true})
    : _plain = false;

  /// No required/optional marker: for read-only fields, and for short forms
  /// where every field is required (an asterisk on each is just noise).
  const FieldLabel.plain(this.text, {super.key})
    : isRequired = false,
      _plain = true;

  final String text;
  final bool isRequired;
  final bool _plain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (_plain)
              const TextSpan()
            else if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.primary),
              )
            else
              TextSpan(
                text: '  (optional)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

/// Error text for non-TextField inputs (chips, pickers), styled like
/// `InputDecoration.errorText`.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(
          message!,
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ),
    );
  }
}
