import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/strings.dart';
import '../core/widgets/dock_nav_bar.dart';
import '../features/bids/presentation/bid_simulator.dart';
import '../features/create_shipment/presentation/open_post_load.dart';
import '../features/notifications/presentation/in_app_alerts.dart';
import '../features/shipments/presentation/shipments_providers.dart';

/// Bottom navigation: Home, Shipments, Post load, Analytics, Account.
/// Post load is the raised centre action and opens the create flow over the
/// current tab instead of switching tabs.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int branch) {
    navigationShell.goBranch(
      branch,
      // Tapping the current tab again returns to its first screen.
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Session-scoped background behaviour: simulated carrier bids and
    // in-app alerts for new activity.
    ref.watch(bidSimulatorProvider);
    final offersToReview = ref.watch(offersToReviewCountProvider);
    return InAppAlerts(
      child: Scaffold(
        // The body runs under the transparent strip around the raised Post
        // load button; screens still pad for the bar itself (via SafeArea).
        extendBody: true,
        body: Builder(
          builder: (context) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                padding: mq.padding.copyWith(
                  bottom: mq.padding.bottom - DockNavBar.overhang,
                ),
              ),
              child: navigationShell,
            );
          },
        ),
        bottomNavigationBar: DockNavBar(
          selectedIndex: navigationShell.currentIndex,
          onSelect: (branch) {
            HapticFeedback.selectionClick();
            _goBranch(branch);
          },
          actionLabel: l10n.navPostLoad,
          actionSemanticLabel: l10n.navPostNewLoad,
          onAction: () {
            HapticFeedback.mediumImpact();
            openPostLoad(context, ref);
          },
          items: [
            DockItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: l10n.navHome,
            ),
            DockItem(
              icon: Icons.local_shipping_outlined,
              selectedIcon: Icons.local_shipping_rounded,
              label: l10n.navShipments,
              badgeCount: offersToReview,
            ),
            DockItem(
              icon: Icons.insert_chart_outlined_rounded,
              selectedIcon: Icons.insert_chart_rounded,
              label: l10n.navAnalytics,
            ),
            DockItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: l10n.navAccount,
            ),
          ],
        ),
      ),
    );
  }
}
