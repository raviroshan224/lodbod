import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/navigation_parts.dart';
import '../../core/widgets/visuals.dart';
import '../../data/providers.dart';
import '../../domain/request_limit.dart';
import '../../routing/routes.dart';
import '../auth/session.dart';
import '../create_shipment/create_shipment_controller.dart';
import '../shipments/request_limit_sheet.dart';
import '../shipments/shipments_providers.dart';
import 'feedback_sheet.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _loadingSamples = false;
  bool _signingOut = false;
  bool _sendingVerification = false;

  Future<void> _setAlerts({bool? bids, bool? status}) async {
    final user = ref.read(currentUserProvider);
    try {
      await ref
          .read(accountRepositoryProvider)
          .updateProfile(
            user.copyWith(bidAlerts: bids, statusAlerts: status),
            previousPhone: user.phone,
          );
    } catch (e) {
      if (mounted) showMessage(context, mapError(e).message, isError: true);
    }
  }

  Future<void> _verifyEmail() async {
    setState(() => _sendingVerification = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) {
        showMessage(context, 'Verification link sent. Check your inbox.');
      }
    } catch (e) {
      if (mounted) showMessage(context, mapError(e).message, isError: true);
    } finally {
      if (mounted) setState(() => _sendingVerification = false);
    }
  }

  Future<void> _loadSamples() async {
    final ok = await confirmAction(
      context,
      title: 'Load sample shipments?',
      message:
          'Your shipments and bids will be replaced with a sample set (LOD-1001 to LOD-1004) so you can explore every feature. '
          'New references continue from the last one used.',
      confirmLabel: 'Load samples',
      destructive: true,
      icon: Icons.auto_awesome_outlined,
    );
    if (!ok || !mounted) return;
    setState(() => _loadingSamples = true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .loadSampleData(ref.read(currentUserProvider).id);
      ref.read(shipmentListQueryProvider.notifier).clear();
      if (mounted) showMessage(context, 'Sample shipments loaded.');
    } catch (e) {
      if (mounted) showMessage(context, mapError(e).message, isError: true);
    } finally {
      if (mounted) setState(() => _loadingSamples = false);
    }
  }

  Future<void> _signOut() async {
    final hasDraft = ref.read(createShipmentProvider.notifier).hasUserInput;
    final ok = await confirmAction(
      context,
      title: 'Sign out?',
      message: hasDraft
          ? 'Your unfinished load will be kept as a saved draft for next time.'
          : "You'll need to log in again to manage your shipments.",
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
    );
    if (!ok || !mounted) return;
    setState(() => _signingOut = true);
    if (hasDraft) {
      try {
        await ref.read(createShipmentProvider.notifier).saveDraft();
      } catch (_) {
        // Signing out matters more than the draft.
      }
    }
    try {
      await ref.read(authActionsProvider).signOut();
      // The router moves to the login screen.
    } catch (e) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      showMessage(context, mapError(e).message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final session = ref.watch(sessionProvider);
    final verified = session is SessionReady && session.user.emailVerified;
    final usage =
        ref.watch(requestLimitUsageProvider).value ??
        const RequestLimitUsage(used: 0);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.xl),
          children: [
            const TabHeader(title: 'Account', inset: false),
            AppCard(
              onTap: () => context.push(Routes.editProfile),
              child: Row(
                children: [
                  InitialsAvatar(Fmt.initials(user.name), size: 52),
                  Space.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Space.v2,
                        Text(
                          '${user.displayCompany} · Shipper',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            ListGroup(
              title: 'Account',
              children: [
                ListRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile & company',
                  subtitle: '+977 ${user.phone}',
                  onTap: () => context.push(Routes.editProfile),
                ),
                ListRow(
                  icon: Icons.mail_outline_rounded,
                  title: 'Email',
                  subtitle: user.email,
                  trailing: verified
                      ? const Pill(label: 'Verified', style: _verifiedStyle)
                      : TextButton(
                          onPressed: _sendingVerification ? null : _verifyEmail,
                          child: Text(
                            _sendingVerification ? 'Sending…' : 'Verify',
                          ),
                        ),
                ),
                ListRow(
                  icon: Icons.layers_outlined,
                  title: 'Mobile requests',
                  subtitle: '${usage.used} of ${usage.limit} in use',
                  onTap: () => showRequestLimitSheet(context, usage),
                ),
              ],
            ),
            ListGroup(
              title: 'Alerts',
              children: [
                ListRow(
                  icon: Icons.gavel_rounded,
                  title: 'New bids',
                  subtitle: 'Alert me when a carrier bids on my load',
                  trailing: Switch(
                    value: user.bidAlerts,
                    onChanged: (v) => _setAlerts(bids: v),
                  ),
                ),
                ListRow(
                  icon: Icons.local_shipping_outlined,
                  title: 'Delivery updates',
                  subtitle: 'Pickup, on the way and delivered',
                  trailing: Switch(
                    value: user.statusAlerts,
                    onChanged: (v) => _setAlerts(status: v),
                  ),
                ),
              ],
            ),
            ListGroup(
              title: 'Support',
              children: [
                ListRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Help center',
                  onTap: () => context.push(Routes.help),
                ),
                ListRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send feedback',
                  subtitle: 'Report a problem or suggest an idea',
                  onTap: () => showFeedbackSheet(context),
                ),
              ],
            ),
            ListGroup(
              title: 'Legal',
              children: [
                ListRow(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => context.push(Routes.terms),
                ),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () => context.push(Routes.privacy),
                ),
              ],
            ),
            ListGroup(
              title: 'Try it out',
              children: [
                ListRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Load sample shipments',
                  subtitle: 'Explore with example loads, bids and deliveries',
                  trailing: _loadingSamples
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _loadingSamples ? null : _loadSamples,
                ),
              ],
            ),
            Space.v24,
            OutlinedButton.icon(
              onPressed: _signingOut ? null : _signOut,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sign out'),
            ),
            Space.v16,
            const Center(
              child: Text(
                'LODBOD Shipper · version 1.0.0',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _verifiedStyle = StatusStyle(
  AppColors.success,
  AppColors.successSoft,
  Icons.verified_rounded,
);
