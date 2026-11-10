import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection and field names in one place.
abstract final class Col {
  static const users = 'users';
  static const shipments = 'shipments';
  static const bids = 'bids';
  static const meta = 'meta';
  static const countersDoc = 'counters';
  static const phoneIndex = 'phoneIndex';
  static const drafts = 'drafts';
  static const currentDraft = 'current';
  static const feedback = 'feedback';
}

abstract final class Fields {
  static const shipperId = 'shipperId';
  static const shipmentId = 'shipmentId';
  static const status = 'status';
  static const activeRequestCount = 'activeRequestCount';
  static const nextShipmentNumber = 'nextShipmentNumber';
  static const seedVersion = 'seedVersion';
  static const seededAt = 'seededAt';
  static const notificationsSeenAt = 'notificationsSeenAt';
}

/// Strict readers for the feature mappers. Each throws [FormatException] for
/// a missing or invalid required field, so a malformed document is skipped
/// (see `parseDocs`) instead of shown half-empty.
abstract final class FirestoreRead {
  static String string(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is String && v.isNotEmpty) return v;
    throw FormatException('Missing "$key"');
  }

  static num number(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is num) return v;
    throw FormatException('Missing "$key"');
  }

  static DateTime date(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is Timestamp) return v.toDate();
    throw FormatException('Missing "$key"');
  }

  static T enumValue<T>(
    Map<String, dynamic> m,
    String key,
    T? Function(String?) parse,
  ) {
    final v = parse(m[key] as String?);
    if (v != null) return v;
    throw FormatException('Invalid "$key"');
  }
}
