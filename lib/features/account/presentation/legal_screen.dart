import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/navigation_parts.dart';

enum LegalDoc { terms, privacy }

/// Plain-language summaries shown in the app. The full legal text would be
/// served from the LODBOD website in production.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  static const _terms = [
    (
      'Using LODBOD',
      'LODBOD connects shippers with independent carriers. You must provide accurate details about your loads, routes and contacts.',
    ),
    (
      'Posting loads',
      'A posted load is an invitation for carriers to bid. Mobile accounts can have up to 3 open requests at a time; additional requests can be created on the LODBOD web platform.',
    ),
    (
      'Bids and bookings',
      'A booking is made only when you accept a bid and confirm it. Accepting one bid declines the others for that load.',
    ),
    (
      'Cancellations',
      'You can cancel a request before pickup. Repeated late cancellations may affect your access.',
    ),
    (
      'Payments',
      'Fares are agreed between you and the carrier in Nepali rupees. Payment terms are shown before you confirm a booking.',
    ),
  ];

  static const _privacy = [
    (
      'What we collect',
      'Your name, phone number, email, company, and the details of loads you post, bids you receive and bookings you make.',
    ),
    (
      'How we use it',
      'To run your account, show your loads to carriers, process bookings, send service messages and improve LODBOD.',
    ),
    (
      'What carriers see',
      'Carriers see your company name, the route, cargo and schedule. Your phone number is shared only with the carrier you book.',
    ),
    (
      'Your choices',
      'You can update your profile at any time and control in-app alerts from Account.',
    ),
    (
      'Security',
      'Your data is stored with industry-standard encryption in transit and at rest.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isTerms = doc == LegalDoc.terms;
    final sections = isTerms ? _terms : _privacy;
    return Scaffold(
      appBar: DetailAppBar(
        title: isTerms ? 'Terms of Service' : 'Privacy Policy',
        subtitle: 'Summary · updated 8 Nov 2026',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.xxl),
        children: [
          for (final (title, body) in sections) ...[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Space.v6,
            Text(
              body,
              style: const TextStyle(
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
