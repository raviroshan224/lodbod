import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/navigation_parts.dart';

enum LegalDoc { terms, privacy }

/// Plain-language summaries shown in the app. The full legal text would be
/// served from the LODBOD website in production.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  static final _terms = [
    (l10n.legalT1, l10n.legalT1Body),
    (l10n.legalT2, l10n.legalT2Body),
    (l10n.legalT3, l10n.legalT3Body),
    (l10n.legalT4, l10n.legalT4Body),
    (l10n.legalT5, l10n.legalT5Body),
  ];

  static final _privacy = [
    (l10n.legalP1, l10n.legalP1Body),
    (l10n.legalP2, l10n.legalP2Body),
    (l10n.legalP3, l10n.legalP3Body),
    (l10n.legalP4, l10n.legalP4Body),
    (l10n.legalP5, l10n.legalP5Body),
  ];

  @override
  Widget build(BuildContext context) {
    final isTerms = doc == LegalDoc.terms;
    final sections = isTerms ? _terms : _privacy;
    return Scaffold(
      appBar: DetailAppBar(
        title: isTerms ? l10n.legalTerms : l10n.legalPrivacy,
        subtitle: l10n.legalSummaryUpdated,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.xxl),
        children: [
          for (final (title, body) in sections) ...[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Space.v6,
            Text(
              body,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.55,
                fontSize: 14.5,
              ),
            ),
            Space.v20,
          ],
        ],
      ),
    );
  }
}
