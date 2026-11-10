import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../features/bids/bid_simulator.dart';
import '../features/create_shipment/open_post_load.dart';
import '../features/notifications/in_app_alerts.dart';

/// Material 3 navigation bar: Home, Shipments, Post load, Analytics,
/// Account. Post load is styled as the bar's primary action and opens the
/// create flow over the current tab instead of switching tabs.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Bar position of the Post load action.
  static const _postLoadSlot = 2;

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
    final branch = navigationShell.currentIndex;
    return InAppAlerts(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: MediaQuery.withClampedTextScaling(
          // The bar has a fixed height: cap label scaling like system bars.
          maxScaleFactor: 1.15,
          child: NavigationBar(
            selectedIndex: branch >= _postLoadSlot ? branch + 1 : branch,
            onDestinationSelected: (i) {
              if (i == _postLoadSlot) {
                HapticFeedback.mediumImpact();
                openPostLoad(context, ref);
                return;
              }
              HapticFeedback.selectionClick();
              _goBranch(i > _postLoadSlot ? i - 1 : i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping_rounded),
                label: 'Shipments',
              ),
              NavigationDestination(
                icon: _PostLoadIcon(),
                label: 'Post load',
                tooltip: 'Post a new load',
              ),
              NavigationDestination(
                icon: Icon(Icons.insert_chart_outlined_rounded),
                selectedIcon: Icon(Icons.insert_chart_rounded),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bar's primary action: a filled brand pill, as wide as the selected
/// indicator, so it reads as "create" rather than as a tab.
class _PostLoadIcon extends StatelessWidget {
  const _PostLoadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
    );
  }
}
