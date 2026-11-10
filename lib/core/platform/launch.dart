import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/feedback.dart';

/// Opens the phone dialer for a Nepali number (10 digits, no country code).
Future<void> callNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: '+977$phone');
  var opened = false;
  try {
    opened = await launchUrl(uri);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showMessage(
      context,
      "Couldn't open the phone app. The number is +977 $phone.",
      isError: true,
    );
  }
}
