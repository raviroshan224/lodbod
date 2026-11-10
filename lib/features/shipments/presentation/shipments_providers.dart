import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/presentation/session.dart';
import '../../bids/data/providers.dart';
import '../../bids/domain/bid.dart';
import '../../notifications/domain/activity.dart';
import '../data/providers.dart';
import '../domain/request_limit.dart';
import '../domain/shipment.dart';
import '../domain/shipment_query.dart';

/// Single source of truth for the shipper's shipments. Dashboard counts, the
/// list, details, analytics, notifications and the request-limit indicator
/// are all derived from this stream, so they can't disagree.
final shipmentsProvider = StreamProvider<List<Shipment>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(shipmentRepositoryProvider).watchShipments(uid);
});

/// Loads with offers waiting for a decision (the Shipments tab badge).
final offersToReviewCountProvider = Provider<int>(
  (ref) => (ref.watch(shipmentsProvider).value ?? const <Shipment>[])
      .where(awaitsShipperDecision)
      .length,
);

final shipmentSummaryProvider = Provider<AsyncValue<ShipmentSummary>>(
  (ref) => ref.watch(shipmentsProvider).whenData(ShipmentSummary.from),
);

final requestLimitUsageProvider = Provider<AsyncValue<RequestLimitUsage>>(
  (ref) => ref.watch(shipmentsProvider).whenData(RequestLimit.usageOf),
);

/// One shipment from the shared list (`null` if it doesn't exist).
final shipmentByIdProvider = Provider.family<AsyncValue<Shipment?>, String>(
  (ref, id) => ref
      .watch(shipmentsProvider)
      .whenData((list) => list.where((s) => s.id == id).firstOrNull),
);

/// Bids for one shipment, live.
final bidsProvider = StreamProvider.autoDispose.family<List<Bid>, String>((
  ref,
  shipmentId,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref
      .watch(bidRepositoryProvider)
      .watchBids(shipmentId: shipmentId, shipperId: uid);
});

/// Every bid on the shipper's shipments.
final shipperBidsProvider = StreamProvider<List<Bid>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(bidRepositoryProvider).watchBidsForShipper(uid);
});

/// Notifications feed, newest first.
final activityFeedProvider = Provider<AsyncValue<List<ActivityItem>>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  final bids = ref.watch(shipperBidsProvider);
  if (shipments.hasError) {
    return AsyncError(shipments.error!, shipments.stackTrace!);
  }
  if (!shipments.hasValue || !bids.hasValue) return const AsyncLoading();
  return AsyncData(buildActivityFeed(shipments.value!, bids.value!));
});

final unreadActivityCountProvider = Provider<int>((ref) {
  final session = ref.watch(sessionProvider);
  final seen = session is SessionReady
      ? session.profile.notificationsSeenAt
      : null;
  final feed = ref.watch(activityFeedProvider).value ?? const [];
  if (seen == null) return 0;
  return feed.where((a) => a.at.isAfter(seen)).length;
});

/// Search text, status filter and sort for the Shipments tab. Kept alive so
/// a dashboard tile can set the filter before switching tabs.
class ShipmentListQuery {
  const ShipmentListQuery({
    this.search = '',
    this.filter = ShipmentFilter.all,
    this.sort = ShipmentSort.newest,
  });
  final String search;
  final ShipmentFilter filter;
  final ShipmentSort sort;

  bool get isFiltered =>
      search.trim().isNotEmpty || filter != ShipmentFilter.all;

  ShipmentListQuery copyWith({
    String? search,
    ShipmentFilter? filter,
    ShipmentSort? sort,
  }) => ShipmentListQuery(
    search: search ?? this.search,
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
  );
}

class ShipmentListQueryController extends Notifier<ShipmentListQuery> {
  @override
  ShipmentListQuery build() {
    ref.watch(currentUidProvider); // Reset when the account changes.
    return const ShipmentListQuery();
  }

  void setSearch(String value) => state = state.copyWith(search: value);
  void setFilter(ShipmentFilter filter) =>
      state = state.copyWith(filter: filter);
  void setSort(ShipmentSort sort) => state = state.copyWith(sort: sort);

  /// Used by dashboard tiles: show exactly that group.
  void showOnly(ShipmentFilter filter) =>
      state = ShipmentListQuery(filter: filter, sort: state.sort);

  void clear() => state = ShipmentListQuery(sort: state.sort);
}

final shipmentListQueryProvider =
    NotifierProvider<ShipmentListQueryController, ShipmentListQuery>(
      ShipmentListQueryController.new,
    );

final filteredShipmentsProvider = Provider<AsyncValue<List<Shipment>>>((ref) {
  final query = ref.watch(shipmentListQueryProvider);
  return ref
      .watch(shipmentsProvider)
      .whenData(
        (list) => query.sort.apply(
          applyShipmentQuery(list, query: query.search, filter: query.filter),
        ),
      );
});

/// Actions on one shipment. State is the action currently running (or null),
/// which the UI uses to disable buttons and show progress; a second call
/// while one is running is ignored, preventing double submissions.
enum ShipmentAction { cancel, carrierUpdate, simulateBids, acceptBid }

class ShipmentActionsController extends Notifier<ShipmentAction?> {
  ShipmentActionsController(this.shipmentId);
  final String shipmentId;

  @override
  ShipmentAction? build() => null;

  Future<AppException?> cancel() => _run(
    ShipmentAction.cancel,
    () => ref.read(shipmentRepositoryProvider).cancelShipment(shipmentId),
  );

  Future<AppException?> applyCarrierUpdate(ShipmentStatus from) => _run(
    ShipmentAction.carrierUpdate,
    () => ref
        .read(shipmentRepositoryProvider)
        .applyCarrierUpdate(shipmentId: shipmentId, from: from),
  );

  Future<AppException?> simulateBids() => _run(
    ShipmentAction.simulateBids,
    () => ref.read(bidRepositoryProvider).simulateIncomingBids(shipmentId),
  );

  /// Resolves only after the server has committed, so the UI never shows an
  /// accepted bid that didn't actually go through.
  Future<AppException?> acceptBid(String bidId) => _run(
    ShipmentAction.acceptBid,
    () => ref
        .read(bidRepositoryProvider)
        .acceptBid(shipmentId: shipmentId, bidId: bidId),
  );

  /// Returns `null` on success, the failure otherwise.
  Future<AppException?> _run(
    ShipmentAction action,
    Future<void> Function() body,
  ) async {
    if (state != null) return null; // Already running: ignore repeat taps.
    state = action;
    try {
      await body();
      return null;
    } catch (e) {
      return mapError(e);
    } finally {
      if (ref.mounted) state = null;
    }
  }
}

final shipmentActionsProvider = NotifierProvider.autoDispose
    .family<ShipmentActionsController, ShipmentAction?, String>(
      ShipmentActionsController.new,
    );
