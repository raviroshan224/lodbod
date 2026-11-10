import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/errors/app_exception.dart';
import 'package:lodbod/features/create_shipment/domain/shipment_draft.dart';
import 'package:lodbod/features/create_shipment/presentation/create_shipment_controller.dart';
import 'package:lodbod/features/shipments/domain/shipment.dart';
import 'package:lodbod/features/shipments/presentation/shipments_providers.dart';

import '../helpers.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ProviderContainer container;
  late String uid;
  String seedId(int n) => seedIdFor(uid, n);

  CreateShipmentController controller() =>
      container.read(createShipmentProvider.notifier);
  ShipmentDraft draft() => container.read(createShipmentProvider).draft;

  void fillValidDraft() {
    controller().edit(
      (d) => d.copyWith(
        pickup: 'Pokhara',
        destination: 'Butwal',
        pickupDate: DateTime(2026, 11, 9),
        pickupTime: const PickupTime(8, 0),
        category: CargoCategory.fmcg,
        description: 'Biscuit cartons',
        weightText: '6',
        vehicleType: VehicleType.closedTruck,
        fareText: '21000',
        notes: 'Handle with care',
      ),
    );
  }

  /// Waits until the live shipment stream reflects [test].
  Future<List<Shipment>> shipmentsWhere(
    bool Function(List<Shipment>) test,
  ) async {
    for (var i = 0; i < 50; i++) {
      final list = await container.read(shipmentsProvider.future);
      if (test(list)) return list;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw StateError('Condition not reached');
  }

  setUp(() async {
    db = FakeFirebaseFirestore();
    (container, uid) = await signedInContainer(db);
    // Keep the shipment stream alive for the whole test.
    container.listen(shipmentsProvider, (_, _) {});
    await container.read(shipmentsProvider.future);
  });

  tearDown(() => container.dispose());

  group('three-request limit through the create flow', () {
    test('at the limit, submit fails with the prescribed message and keeps the draft', () async {
      fillValidDraft();
      final before = draft();

      final result = await controller().submit();

      expect(result, isA<SubmitFailed>());
      final error = (result as SubmitFailed).error;
      expect(error, isA<RequestLimitReachedException>());
      expect(
        error.message,
        startsWith('You have reached the mobile request limit of 3.'),
      );

      final state = container.read(createShipmentProvider);
      expect(state.submitting, isFalse);
      expect(state.submitError, isA<RequestLimitReachedException>());
      // Every value the user typed is still there.
      expect(identical(state.draft, before), isTrue);
      expect(state.draft.pickup, 'Pokhara');
      expect(state.draft.notes, 'Handle with care');
    });

    test('after a slot frees up, the preserved draft submits and every view updates', () async {
      fillValidDraft();
      await controller().submit(); // Rejected: at limit.

      final cancelError = await container
          .read(shipmentActionsProvider(seedId(1002)).notifier)
          .cancel();
      expect(cancelError, isNull);
      await shipmentsWhere(
        (l) => l.any((s) => s.status == ShipmentStatus.cancelled),
      );
      expect(container.read(requestLimitUsageProvider).value!.used, 2);

      final result = await controller().submit();
      expect(result, isA<SubmitSucceeded>());
      final created = (result as SubmitSucceeded).shipment;
      expect(created.reference, 'LOD-1005');
      expect(created.status, ShipmentStatus.awaitingBids);

      // Form resets only after success.
      expect(container.read(createShipmentProvider).draft.pickup, isEmpty);
      expect(
        container.read(createShipmentProvider).lastCreated?.id,
        created.id,
      );

      // Dashboard counts, list and limit all come from the same stream.
      final list = await shipmentsWhere(
        (l) => l.any((s) => s.id == created.id),
      );
      expect(list.first.id, created.id); // Newest first.
      final summary = container.read(shipmentSummaryProvider).value!;
      expect(summary.awaitingBids, 1); // New one (LOD-1002 was cancelled).
      expect(summary.total, 5);
      expect(
        container.read(requestLimitUsageProvider).value!.isAtLimit,
        isTrue,
      );
      expect(
        container.read(shipmentByIdProvider(created.id)).value?.reference,
        'LOD-1005',
      );
    });
  });

  test(
    'a second submit while one is in flight is ignored (no duplicate)',
    () async {
      await container
          .read(shipmentActionsProvider(seedId(1002)).notifier)
          .cancel();
      fillValidDraft();

      final results = await Future.wait([
        controller().submit(),
        controller().submit(),
      ]);

      expect(results.whereType<SubmitSucceeded>().length, 1);
      expect(results.whereType<SubmitIgnored>().length, 1);
      final created = await db
          .collection('shipments')
          .where('reference', isEqualTo: 'LOD-1005')
          .get();
      expect(created.docs.length, 1);
      expect(
        (await db
                .collection('shipments')
                .where('reference', isEqualTo: 'LOD-1006')
                .get())
            .docs,
        isEmpty,
      );
    },
  );

  test(
    'an invalid draft is not submitted and jumps to the first bad step',
    () async {
      fillValidDraft();
      controller().edit((d) => d.copyWith(weightText: '0'));
      controller().goTo(DraftStep.vehicle);

      final result = await controller().submit();

      expect(result, isA<SubmitInvalid>());
      final state = container.read(createShipmentProvider);
      expect(state.step, DraftStep.cargo);
      expect(
        controller().visibleErrors(DraftStep.cargo)[DraftField.weight],
        isNotNull,
      );
    },
  );

  test('today, passed times can\'t be chosen and a stale time is dropped', () {
    // The test clock reads 7 Nov 2026, 10:00.
    final today = DateTime(2026, 11, 7);
    controller().selectPickupDate(DateTime(2026, 11, 8));
    expect(controller().selectPickupTime(const PickupTime(8, 0)), isTrue);

    // Switching to today drops 08:00 instead of keeping an invalid time.
    controller().selectPickupDate(today);
    expect(draft().pickupDate, today);
    expect(draft().pickupTime, isNull);

    expect(controller().selectPickupTime(const PickupTime(8, 0)), isFalse);
    expect(draft().pickupTime, isNull);
    expect(controller().selectPickupTime(const PickupTime(15, 0)), isTrue);
    expect(draft().pickupTime, const PickupTime(15, 0));
  });

  group('bid acceptance', () {
    String himalayan() => '${seedId(1002)}_a';
    String swift() => '${seedId(1002)}_b';

    test(
      'accepting updates shipment, bids and dashboard consistently',
      () async {
        final actions = container.read(
          shipmentActionsProvider(seedId(1002)).notifier,
        );
        container.listen(shipmentActionsProvider(seedId(1002)), (_, _) {});

        expect(await actions.acceptBid(himalayan()), isNull);

        final list = await shipmentsWhere(
          (l) => l.any(
            (s) => s.id == seedId(1002) && s.status == ShipmentStatus.confirmed,
          ),
        );
        final s = list.firstWhere((s) => s.id == seedId(1002));
        expect(s.carrierName, 'Himalayan Cargo');
        expect(s.agreedFare, 32000);

        final summary = container.read(shipmentSummaryProvider).value!;
        expect(summary.awaitingBids, 0);
        expect(summary.active, 3);
      },
    );

    test('accepting a different bid afterwards is refused', () async {
      final actions = container.read(
        shipmentActionsProvider(seedId(1002)).notifier,
      );
      container.listen(shipmentActionsProvider(seedId(1002)), (_, _) {});
      await actions.acceptBid(himalayan());

      final error = await actions.acceptBid(swift());
      expect(error, isA<BidAlreadyAcceptedException>());
    });

    test('a double tap runs the accept only once', () async {
      final actions = container.read(
        shipmentActionsProvider(seedId(1002)).notifier,
      );
      container.listen(shipmentActionsProvider(seedId(1002)), (_, _) {});

      final first = actions.acceptBid(himalayan());
      expect(
        container.read(shipmentActionsProvider(seedId(1002))),
        ShipmentAction.acceptBid,
      );
      // A second tap (even on another bid) while the first is running is ignored.
      final second = actions.acceptBid(swift());
      expect(await first, isNull);
      expect(await second, isNull);

      final bids = await db
          .collection('bids')
          .where('shipmentId', isEqualTo: seedId(1002))
          .get();
      final accepted = bids.docs
          .where((d) => d.data()['status'] == 'accepted')
          .map((d) => d.id);
      expect(accepted, [himalayan()]);
    });
  });
}
