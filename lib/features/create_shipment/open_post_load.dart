import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../routing/routes.dart';
import '../shipments/request_limit_sheet.dart';
import '../shipments/shipments_providers.dart';

/// Every way into Post Load goes through here. With all mobile requests in
/// use, the limit is explained before the form opens, so nobody fills in a
/// load they can't post. Submitting still checks the limit (the create
/// transaction enforces it) in case another device posts in the meantime.
///
/// [replace] navigates with `go` instead of `push`.
void openPostLoad(BuildContext context, WidgetRef ref, {bool replace = false}) {
  if (explainLimitIfReached(context, ref)) return;
  if (replace) {
    context.go(Routes.postLoad);
  } else {
    context.push(Routes.postLoad);
  }
}

/// When no more loads can be posted from mobile, shows the request-limit
/// sheet and returns true. While usage is still loading it returns false:
/// the form and the submit check cover that case.
bool explainLimitIfReached(BuildContext context, WidgetRef ref) {
  final usage = ref.read(requestLimitUsageProvider).value;
  if (usage == null || !usage.isAtLimit) return false;
  showRequestLimitSheet(
    context,
    usage,
    blocked: true,
    detailsSaved: false,
  ).ignore();
  return true;
}
