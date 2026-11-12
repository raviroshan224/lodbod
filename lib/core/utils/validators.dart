import '../l10n/strings.dart';

/// Field-level validators shared by login and the shipment form. Each returns
/// `null` when valid or a user-facing message otherwise, matching
/// `FormField.validator`.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Nepali mobile numbers: 10 digits starting 97/98, optionally prefixed
  /// with +977 / 977. Spaces and dashes are ignored.
  static final _nepaliMobile = RegExp(r'^(?:\+?977)?(9[78]\d{8})$');

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return l10n.vRequired(label);
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.vEmailRequired;
    if (!_email.hasMatch(v)) {
      return l10n.vEmailInvalid;
    }
    return null;
  }

  static String? phone(String? value, {bool isRequired = true}) {
    final v = normalizePhone(value ?? '');
    if (v.isEmpty) return isRequired ? l10n.vPhoneRequired : null;
    if (!_nepaliMobile.hasMatch(v)) {
      return l10n.vPhoneInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.vPasswordRequired;
    if (v.length < 8) return l10n.vPasswordMin;
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.vNameRequired;
    if (v.length < 2) return l10n.vNameInvalid;
    return null;
  }

  /// Password rules for new accounts: 8+ characters with a letter and a
  /// number.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.vPasswordRequired;
    if (v.length < 8) return l10n.vPasswordUseEight;
    if (!RegExp(r'[0-9]').hasMatch(v) || !RegExp(r'[A-Za-z]').hasMatch(v)) {
      return l10n.vPasswordLetterNumber;
    }
    return null;
  }

  /// 0 (empty) to 3 (strong), for the password strength hint. A password
  /// that fails [newPassword] is always weak, so the hint never praises a
  /// password the form will reject.
  static int passwordStrength(String v) {
    if (v.isEmpty) return 0;
    if (newPassword(v) != null) return 1;
    return v.length >= 12 || RegExp(r'[^A-Za-z0-9]').hasMatch(v) ? 3 : 2;
  }

  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.vIdentifierRequired;
    return v.contains('@') ? email(v) : phone(v);
  }

  /// Strips spaces/dashes and the +977 country code so numbers compare
  /// reliably: "+977 98-0000-0001" → "9800000001".
  static String normalizePhone(String value) {
    final compact = value.replaceAll(RegExp(r'[\s-]'), '');
    final match = _nepaliMobile.firstMatch(compact);
    return match?.group(1) ?? compact;
  }
}
