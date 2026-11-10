import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Always-visible prefix such as "📞 +977" or "💳 Rs.".
/// (`InputDecoration.prefixText` only appears once the field is focused,
/// which leaves an odd gap before the hint.)
class FieldPrefix extends StatelessWidget {
  const FieldPrefix({super.key, required this.icon, required this.text})
    : divider = false;

  const FieldPrefix.phone({super.key})
    : icon = Icons.phone_outlined,
      text = '+977',
      divider = false;

  /// "+977 |" with no icon, for plain forms where an icon would be noise.
  const FieldPrefix.dialCode({super.key})
    : icon = null,
      text = '+977',
      divider = true;

  const FieldPrefix.rupees({super.key})
    : icon = Icons.account_balance_wallet_outlined,
      text = 'Rs.',
      divider = false;

  final IconData? icon;
  final String text;

  /// A thin rule between the prefix and what the user types.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: icon == null ? 14 : 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (divider) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 22, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}
