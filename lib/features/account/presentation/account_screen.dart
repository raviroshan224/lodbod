import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/choice_sheet.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/visuals.dart';
import '../../../routing/routes.dart';
import '../../auth/data/providers.dart';
import '../../auth/presentation/session.dart';
import '../../create_shipment/presentation/create_shipment_controller.dart';
import '../../shipments/domain/request_limit.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/request_limit_sheet.dart';
import '../data/providers.dart';
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
        showMessage(context, l10n.verifyLinkSent);
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
      title: l10n.accountLoadSamplesTitle,
      message: l10n.accountLoadSamplesBody,
      confirmLabel: l10n.accountLoadSamplesConfirm,
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
      if (mounted) showMessage(context, l10n.accountSamplesLoaded);
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
      title: l10n.accountSignOutTitle,
      message: hasDraft ? l10n.accountSignOutDraft : l10n.accountSignOutBody,
      confirmLabel: l10n.actionSignOut,
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
    final settings = ref.watch(settingsProvider);
    final alertsOn = user.bidAlerts || user.statusAlerts;
    final usage =
        ref.watch(requestLimitUsageProvider).value ??
        const RequestLimitUsage(used: 0);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Gap.page,
            0,
            Gap.page,
            Gap.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            TabHeader(title: l10n.navAccount, inset: false),
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
                          l10n.accountShipperLine(user.displayCompany),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
            ListGroup(
              title: l10n.navAccount,
              children: [
                ListRow(
                  icon: Icons.person_outline_rounded,
                  title: l10n.accountProfile,
                  onTap: () => context.push(Routes.editProfile),
                ),
                ListRow(
                  icon: Icons.mail_outline_rounded,
                  title: l10n.fieldEmail,
                  value: verified ? null : user.email,
                  trailing: verified
                      ? Pill(label: l10n.accountVerified, style: _verifiedStyle)
                      : TextButton(
                          onPressed: _sendingVerification ? null : _verifyEmail,
                          child: Text(
                            _sendingVerification
                                ? l10n.accountSending
                                : l10n.accountVerify,
                          ),
                        ),
                ),
                ListRow(
                  icon: Icons.layers_outlined,
                  title: l10n.accountMobileRequests,
                  value: l10n.homeUsedOfInUse(usage.used, usage.limit),
                  onTap: () => showRequestLimitSheet(context, usage),
                ),
              ],
            ),
            ListGroup(
              title: l10n.accountPreferences,
              children: [
                ListRow(
                  icon: Icons.translate_rounded,
                  title: l10n.accountLanguage,
                  value: settings.language.nativeName,
                  onTap: () async {
                    final choice = await showChoiceSheet<AppLanguage>(
                      context,
                      title: l10n.accountLanguage,
                      selected: settings.language,
                      options: [
                        for (final l in AppLanguage.values)
                          ChoiceOption(l, l.nativeName),
                      ],
                    );
                    if (choice != null) {
                      await ref
                          .read(settingsProvider.notifier)
                          .setLanguage(choice);
                    }
                  },
                ),
                ListRow(
                  icon: Icons.brightness_6_outlined,
                  title: l10n.accountAppearance,
                  value: _appearanceLabel(settings.appearance),
                  onTap: () async {
                    final choice = await showChoiceSheet<Appearance>(
                      context,
                      title: l10n.accountAppearance,
                      selected: settings.appearance,
                      options: [
                        for (final a in Appearance.values)
                          ChoiceOption(
                            a,
                            _appearanceLabel(a),
                            icon: switch (a) {
                              Appearance.system =>
                                Icons.brightness_auto_outlined,
                              Appearance.light => Icons.light_mode_outlined,
                              Appearance.dark => Icons.dark_mode_outlined,
                            },
                          ),
                      ],
                    );
                    if (choice != null) {
                      await ref
                          .read(settingsProvider.notifier)
                          .setAppearance(choice);
                    }
                  },
                ),
                ListRow(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifTitle,
                  trailing: _CompactSwitch(
                    value: alertsOn,
                    onChanged: (v) => _setAlerts(bids: v, status: v),
                  ),
                ),
                if (alertsOn) ...[
                  ListRow(
                    icon: Icons.gavel_rounded,
                    title: l10n.accountNewBidAlerts,
                    trailing: _CompactSwitch(
                      value: user.bidAlerts,
                      onChanged: (v) => _setAlerts(bids: v),
                    ),
                  ),
                  ListRow(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.accountDeliveryUpdates,
                    trailing: _CompactSwitch(
                      value: user.statusAlerts,
                      onChanged: (v) => _setAlerts(status: v),
                    ),
                  ),
                ],
              ],
            ),
            ListGroup(
              title: l10n.accountSupport,
              children: [
                ListRow(
                  icon: Icons.help_outline_rounded,
                  title: l10n.accountHelpCenter,
                  onTap: () => context.push(Routes.help),
                ),
                ListRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.accountSendFeedback,
                  onTap: () => showFeedbackSheet(context),
                ),
              ],
            ),
            ListGroup(
              title: l10n.accountLegal,
              children: [
                ListRow(
                  icon: Icons.description_outlined,
                  title: l10n.legalTerms,
                  onTap: () => context.push(Routes.terms),
                ),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: l10n.legalPrivacy,
                  onTap: () => context.push(Routes.privacy),
                ),
              ],
            ),
            ListGroup(
              title: l10n.accountDemo,
              children: [
                ListRow(
                  icon: Icons.auto_awesome_outlined,
                  title: l10n.accountLoadSamples,
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
              label: Text(l10n.actionSignOut),
            ),
            Space.v16,
            Center(
              child: Text(
                l10n.appVersionLine('1.0.0'),
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

StatusStyle get _verifiedStyle => StatusStyle(
  AppColors.success,
  AppColors.successSoft,
  Icons.verified_rounded,
);

/// Switch sized to a single-line settings row.
class _CompactSwitch extends StatelessWidget {
  const _CompactSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: FittedBox(
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

String _appearanceLabel(Appearance a) => switch (a) {
  Appearance.system => l10n.appearanceSystem,
  Appearance.light => l10n.appearanceLight,
  Appearance.dark => l10n.appearanceDark,
};
