import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shipment.dart';
import '../../data/providers.dart';
import '../../domain/simulated_driver.dart';
import '../../domain/tracking.dart';
import 'shipments_providers.dart';

/// The latest position report for a shipment, live over Firestore. Null
/// before the first report, and while it can't be read (offline, or the
/// project's rules don't include tracking yet): screens then show the
/// schedule estimate instead.
final livePositionProvider = StreamProvider.autoDispose
    .family<LivePosition?, String>(
      (ref, shipmentId) =>
          ref.watch(trackingRepositoryProvider).watchPosition(shipmentId),
    );

/// Whether the simulated driver may run. Tests turn it off.
final simulatedDriverEnabledProvider = Provider<bool>((ref) => true);

/// The simulated driver for one shipment, running while something watches
/// it (the tracking screen does): it reports the truck's position every
/// [SimulatedDriver.reportInterval] while the app is in the foreground.
/// Every device watching the shipment receives each report through
/// [livePositionProvider].
final simulatedDriverProvider = Provider.autoDispose.family<void, String>((
  ref,
  shipmentId,
) {
  if (!ref.watch(simulatedDriverEnabledProvider)) return;
  final repository = ref.watch(trackingRepositoryProvider);
  var reporting = false;
  var warned = false;

  Future<void> report() async {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (reporting ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
      return;
    }
    final s = ref.read(shipmentByIdProvider(shipmentId)).value;
    if (s == null || s.status != ShipmentStatus.inTransit) return;
    reporting = true;
    try {
      await repository.reportSimulatedPosition(s);
    } catch (e) {
      // Offline, or the project's rules don't allow tracking yet: the
      // schedule estimate stays on screen. Say why once, for developers.
      if (kDebugMode && !warned) {
        warned = true;
        debugPrint(
          'Simulated driver: position report failed ($e). If this is a '
          'permission error, publish firestore.rules to the Firebase project.',
        );
      }
    } finally {
      reporting = false;
    }
  }

  final timer = Timer.periodic(SimulatedDriver.reportInterval, (_) {
    unawaited(report());
  });
  ref.onDispose(timer.cancel);
  unawaited(report());
});
