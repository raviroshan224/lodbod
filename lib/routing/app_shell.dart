import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../features/bids/bid_simulator.dart';
import '../features/notifications/in_app_alerts.dart';
import 'routes.dart';

/// Bottom navigation: Home, Shipments, Post Load, Analytics, Account.
/// Post Load is a raised action (opens the create flow over the current
/// tab), not a tab.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int branch) {
    HapticFeedback.selectionClick();
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
    return InAppAlerts(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomBar(
          currentBranch: navigationShell.currentIndex,
          onBranch: _goBranch,
          onPostLoad: () {
            HapticFeedback.mediumImpact();
            context.push(Routes.postLoad);
          },
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentBranch,
    required this.onBranch,
    required this.onPostLoad,
  });

  final int currentBranch;
  final ValueChanged<int> onBranch;
  final VoidCallback onPostLoad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                active: currentBranch == 0,
                onTap: () => onBranch(0),
              ),
              _NavItem(
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping_rounded,
                label: 'Shipments',
                active: currentBranch == 1,
                onTap: () => onBranch(1),
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Post a new load',
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onPostLoad,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -6),
                          child: Container(
                            width: 46,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -5),
                          child: const Text(
                            'Post Load',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.insert_chart_outlined_rounded,
                activeIcon: Icons.insert_chart_rounded,
                label: 'Analytics',
                active: currentBranch == 2,
                onTap: () => onBranch(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Account',
                active: currentBranch == 3,
                onTap: () => onBranch(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: active ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(active ? activeIcon : icon, size: 22, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
