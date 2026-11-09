import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shipment.dart';
import '../../data/providers.dart';
import '../shipments/shipments_providers.dart';

/// How long after posting simulated carrier bids arrive.
const simulatedBidDelay = Duration(seconds: 20);

/// Stands in for the carrier marketplace, which this build doesn't have: a
/// little while after a load is posted, sample carrier bids arrive. Runs
/// only while the app is open; the write is idempotent (a shipment that
/// already has bids is skipped by the repository), so several devices can't
/// double up.
final bidSimulatorProvider = Provider<void>((ref) {
  final timers = <String, Timer>{};
  final done = <String>{};
  ref.onDispose(() {
    for (final t in timers.values) {
      t.cancel();
    }
  });

  void schedule(List<Shipment> shipments) {
    final now = DateTime.now();
    for (final s in shipments) {
      if (s.status != ShipmentStatus.awaitingBids ||
          s.bidCount > 0 ||
          done.contains(s.id) ||
          timers.containsKey(s.id)) {
        continue;
      }
      final wait = s.createdAt.add(simulatedBidDelay).difference(now);
      timers[s.id] = Timer(
        wait.isNegative ? const Duration(seconds: 3) : wait,
        () async {
          timers.remove(s.id);
          done.add(s.id);
          if (!ref.mounted) return;
          try {
            await ref.read(bidRepositoryProvider).simulateIncomingBids(s.id);
          } catch (_) {
            // Already has bids, was cancelled, or offline: nothing to do.
          }
        },
      );
    }
  }

  ref.listen<AsyncValue<List<Shipment>>>(
    shipmentsProvider,
    (_, next) => schedule(next.value ?? const []),
    fireImmediately: true,
  );
});
