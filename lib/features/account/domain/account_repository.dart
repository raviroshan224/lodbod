import '../../auth/domain/user_profile.dart';
import '../../create_shipment/domain/shipment_draft.dart';

/// The shipper's profile and per-account data. Every method throws
/// `AppException` subclasses (never SDK errors).
abstract interface class AccountRepository {
  Stream<UserProfile?> watchProfile(String uid);

  /// Creates `users/{uid}` and reserves the phone number for phone sign-in.
  /// Throws `PhoneTakenException` if another account uses the number.
  Future<void> createProfile(String uid, Registration registration);

  Future<void> updateProfile(
    UserProfile profile, {
    required String previousPhone,
  });

  /// Email registered for a phone number, or null.
  Future<String?> emailForPhone(String phone);

  Future<bool> isPhoneRegistered(String phone);

  /// Re-derives the request-limit counter from the shipper's shipments.
  Future<void> reconcileRequestCount(String uid);

  /// Replaces the shipper's shipments and bids with the sample data set.
  Future<void> loadSampleData(String uid);

  /// Reloads the sample data with current dates if it was loaded a while
  /// ago and hasn't been touched since, so a demo account opened days later
  /// still tells a coherent story. Returns whether it refreshed.
  Future<bool> refreshStaleSampleData(String uid);

  Future<void> markNotificationsSeen(String uid);

  Future<void> saveDraft(String uid, ShipmentDraft draft);
  Future<ShipmentDraft?> loadDraft(String uid);
  Future<void> clearDraft(String uid);

  Future<void> sendFeedback(
    String uid, {
    required String topic,
    required String message,
  });
}
