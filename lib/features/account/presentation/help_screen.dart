import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../shipments/domain/request_limit.dart';
import 'feedback_sheet.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static final _faqs = [
    (l10n.helpQ1, l10n.helpA1),
    (l10n.helpQ2, l10n.helpA2(RequestLimit.max)),
    (l10n.helpQ3, l10n.helpA3),
    (l10n.helpQ4, l10n.helpA4),
    (l10n.helpQ5, l10n.helpA5),
    (l10n.helpQ6, l10n.helpA6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(title: l10n.accountHelpCenter),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, Gap.xl),
        children: [
          SectionHeader(l10n.helpFaq, top: 0),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, faq) in _faqs.indexed) ...[
                  if (i > 0) const Divider(),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: Gap.lg,
                        vertical: 2,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        Gap.lg,
                        0,
                        Gap.lg,
                        Gap.lg,
                      ),
                      iconColor: AppColors.primary,
                      collapsedIconColor: AppColors.textMuted,
                      title: Text(
                        faq.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      children: [
                        Text(
                          faq.$2,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Space.v20,
          AppCard(
            child: Row(
              children: [
                const IconTile(Icons.support_agent_rounded, size: 44),
                Space.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helpStillNeed,
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        l10n.helpStillNeedBody,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => showFeedbackSheet(context),
                  child: Text(l10n.helpMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
