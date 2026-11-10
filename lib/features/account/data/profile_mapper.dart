import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_schema.dart';
import '../../auth/domain/user_profile.dart';

/// Reads `users/{uid}` into a [UserProfile]. Kept out of the model so it
/// stays backend-agnostic.
abstract final class ProfileMapper {
  static UserProfile fromMap(String uid, Map<String, dynamic> m) => UserProfile(
    id: uid,
    name: m['name'] as String? ?? '',
    company: m['company'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    email: m['email'] as String? ?? '',
    role: m['role'] as String? ?? '',
    notificationsSeenAt: (m[Fields.notificationsSeenAt] as Timestamp?)
        ?.toDate(),
    bidAlerts: m['bidAlerts'] as bool? ?? true,
    statusAlerts: m['statusAlerts'] as bool? ?? true,
  );
}
