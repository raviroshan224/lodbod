import '../../domain/shipment_draft.dart';
import '../models/bid.dart';
import '../models/shipment.dart';
import '../models/user_profile.dart';

// Contracts the UI depends on. Firebase implementations live in
// `firebase/`; a REST implementation would satisfy the same interfaces and be
// swapped in via the providers in `data/providers.dart`, without changes to
// any screen.
//
// Every method throws `AppException` subclasses (never SDK errors).

abstract interface class AuthRepository {
  /// Emits the signed-in user (or null) now and on every change. Sessions
  /// persist across app restarts.
  Stream<AuthUser?> authStateChanges();

  /// [email] must already be resolved (see [AccountRepository.emailForPhone]).
  Future<void> signIn({required String email, required String password});

  /// Creates the auth account and signs it in.
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();

  /// Refreshes the cached user (e.g. after the email link was opened).
  Future<AuthUser?> reload();

  /// Removes a just-created auth account when profile setup fails.
  Future<void> deleteCurrentUser();

  Future<void> signOut();
}

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

abstract interface class ShipmentRepository {
  /// All of the shipper's shipments, newest first, updated live.
  Stream<List<Shipment>> watchShipments(String shipperId);

  /// A fresh id for one submission attempt. Reusing it on retry makes
  /// [createShipment] idempotent.
  String newRequestId();

  /// Creates a shipment in Awaiting bids. Atomically enforces the request
  /// limit and allocates the next unique reference.
  Future<Shipment> createShipment({
    required String shipperId,
    required String requestId,
    required NewShipment input,
  });

  Future<void> cancelShipment(String shipmentId);

  /// Moves requests still awaiting bids after their pickup time to Expired,
  /// freeing their request slots. Returns how many expired. A server job in
  /// production; here it runs on the client at sign-in.
  Future<int> expireOverdueRequests(String shipperId);

  /// Moves the shipment one step along the carrier lifecycle (simulated
  /// carrier update in this build).
  Future<void> applyCarrierUpdate({
    required String shipmentId,
    required ShipmentStatus from,
  });
}

abstract interface class BidRepository {
  /// Bids on one shipment, oldest first, updated live.
  Stream<List<Bid>> watchBids({
    required String shipmentId,
    required String shipperId,
  });

  /// Every bid on the shipper's shipments (for the activity feed).
  Stream<List<Bid>> watchBidsForShipper(String shipperId);

  /// Accepts [bidId], declines the other bids and confirms the shipment in a
  /// single transaction. Idempotent for the same bid.
  Future<void> acceptBid({required String shipmentId, required String bidId});

  /// Adds simulated carrier bids to a shipment with no bids yet.
  Future<int> simulateIncomingBids(String shipmentId);
}
