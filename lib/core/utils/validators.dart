/// Field-level validators shared by login and the shipment form. Each returns
/// `null` when valid or a user-facing message otherwise, matching
/// `FormField.validator`.
abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Nepali mobile numbers: 10 digits starting 97/98, optionally prefixed
  /// with +977 / 977. Spaces and dashes are ignored.
  static final _nepaliMobile = RegExp(r'^(?:\+?977)?(9[78]\d{8})$');

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_email.hasMatch(v)) {
      return 'Enter a valid email, e.g. name@company.com';
    }
    return null;
  }

  static String? phone(String? value, {bool isRequired = true}) {
    final v = normalizePhone(value ?? '');
    if (v.isEmpty) return isRequired ? 'Phone number is required' : null;
    if (!_nepaliMobile.hasMatch(v)) {
      return 'Enter a 10-digit mobile number starting with 97 or 98';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Enter your full name';
    return null;
  }

  /// Password rules for new accounts: 8+ characters with a letter and a
  /// number.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[0-9]').hasMatch(v) || !RegExp(r'[A-Za-z]').hasMatch(v)) {
      return 'Include at least one letter and one number';
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

  /// Email address or Nepali mobile number.
  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email or phone number';
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
