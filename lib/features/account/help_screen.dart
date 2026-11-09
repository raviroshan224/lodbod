import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/navigation_parts.dart';
import '../../domain/request_limit.dart';
import 'feedback_sheet.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'How do I post a load?',
      'Tap Post Load, enter the route and pickup time, describe the cargo and choose a vehicle. '
          'Review it and post. Carriers can bid straight away.',
    ),
    (
      'Why can I only have 3 open requests?',
      'From the mobile app you can have up to ${RequestLimit.max} requests that are awaiting bids, confirmed, scheduled '
          'or in transit at once. Delivered, cancelled and expired requests free up a slot. '
          'For more volume, use the LODBOD web platform.',
    ),
    (
      'How do I choose a bid?',
      'Open your shipment and tap Compare bids. You can sort by price, rating or delivery time and open any offer '
          'for details. Nothing is booked until you confirm.',
    ),
    (
      'Can I cancel a shipment?',
      'Yes, until pickup. Open the shipment, tap the ⋮ menu and choose Cancel shipment. Open bids are declined.',
    ),
    (
      'Where is my truck?',
      'Booked shipments have a Track shipment screen with the route, checkpoints and estimated arrival. '
          'In this version tracking is simulated from the schedule.',
    ),
    (
      'Will I lose an unfinished load?',
      'No. Drafts are saved to your account when you close Post Load or tap Save draft, so you can finish them later.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DetailAppBar(title: 'Help center'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, Gap.xl),
        children: [
          const SectionHeader('Frequently asked', top: 0),
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
                          style: const TextStyle(
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Still need help?',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Send us a message and the team will get back to you.',
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
                  child: const Text('Message'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
