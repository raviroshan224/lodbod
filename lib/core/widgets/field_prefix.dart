import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Always-visible icon + text prefix such as "📞 +977" or "💳 Rs.".
/// (`InputDecoration.prefixText` only appears once the field is focused,
/// which leaves an odd gap before the hint.)
class FieldPrefix extends StatelessWidget {
  const FieldPrefix({super.key, required this.icon, required this.text});

  const FieldPrefix.phone({super.key})
    : icon = Icons.phone_outlined,
      text = '+977';

  const FieldPrefix.rupees({super.key})
    : icon = Icons.account_balance_wallet_outlined,
      text = 'Rs.';

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
