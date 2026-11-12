import '../../../core/l10n/strings.dart';

/// The signed-in identity, independent of the auth SDK.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
  });

  final String uid;
  final String email;
  final bool emailVerified;
}

/// A shipper's profile, stored at `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    this.role = 'shipper',
    this.notificationsSeenAt,
    this.bidAlerts = true,
    this.statusAlerts = true,
  });

  final String id;
  final String name;
  final String company;
  final String phone;
  final String email;

  /// Only shippers can use this app; checked after sign-in and enforced by
  /// the security rules (clients can't change it).
  final String role;

  /// Activity newer than this is shown as unread.
  final DateTime? notificationsSeenAt;

  final bool bidAlerts;
  final bool statusAlerts;

  bool get isShipper => role == 'shipper';

  String get displayCompany =>
      company.isEmpty ? l10n.individualShipper : company;

  UserProfile copyWith({
    String? name,
    String? company,
    String? phone,
    bool? bidAlerts,
    bool? statusAlerts,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email,
      role: role,
      notificationsSeenAt: notificationsSeenAt,
      bidAlerts: bidAlerts ?? this.bidAlerts,
      statusAlerts: statusAlerts ?? this.statusAlerts,
    );
  }
}

class Registration {
  const Registration({
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.password,
  });

  final String name;

  /// Normalised 10-digit Nepali mobile number.
  final String phone;
  final String email;
  final String company;
  final String password;
}
