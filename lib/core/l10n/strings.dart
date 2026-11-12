import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

import '../settings/app_settings.dart';

export '../../l10n/app_localizations.dart';

/// The current language's strings, for code that has no BuildContext
/// (validators, enum labels, repository messages). Widgets may use it too:
/// the tree is rebuilt whenever the language changes, so a widget never
/// keeps strings from the previous one.
AppLocalizations get l10n => lookupAppLocalizations(AppLanguage.current.locale);

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
