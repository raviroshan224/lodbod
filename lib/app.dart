import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/settings/app_settings.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/account/data/providers.dart';
import 'features/auth/presentation/session.dart';
import 'features/shipments/data/providers.dart';
import 'routing/app_router.dart';

class LodbodApp extends ConsumerStatefulWidget {
  const LodbodApp({super.key});

  @override
  ConsumerState<LodbodApp> createState() => _LodbodAppState();
}

class _LodbodAppState extends ConsumerState<LodbodApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// "System" appearance follows the phone.
  @override
  void didChangePlatformBrightness() => _applyPalette();

  Brightness get _platformBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  /// Switches the static palette and rebuilds every widget. Widgets read
  /// `AppColors` directly rather than through an inherited theme, so no
  /// dependency tells them it changed; marking the tree dirty once does.
  void _applyPalette() {
    final next = ref
        .read(settingsProvider)
        .appearance
        .resolve(_platformBrightness);
    if (next == AppColors.brightness) return;
    AppColors.brightness = next;
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider, (_, _) => _applyPalette());
    final brightness = ref
        .watch(settingsProvider)
        .appearance
        .resolve(_platformBrightness);
    AppColors.brightness = brightness;
    final theme = AppTheme.build(brightness);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.systemBars);

    ref.listen(sessionProvider, (previous, next) {
      switch (next) {
        case SessionWrongRole():
          // Role-based access: only shipper accounts may use this app.
          ref
              .read(authNoticeProvider.notifier)
              .show(
                'This app is for shipper accounts. Carriers use the LODBOD Carrier app.',
              );
          ref.read(authActionsProvider).signOut().ignore();
        case SessionReady(:final profile) when previous is! SessionReady:
          // Once per sign-in: bring untouched sample data up to date, expire
          // requests whose pickup has passed, then heal the request counter
          // if it drifted. Each step is safe to skip if it fails.
          final accounts = ref.read(accountRepositoryProvider);
          final shipments = ref.read(shipmentRepositoryProvider);
          accounts
              .refreshStaleSampleData(profile.id)
              .catchError((_) => false)
              .then((_) => shipments.expireOverdueRequests(profile.id))
              .catchError((_) => 0)
              .then((_) => accounts.reconcileRequestCount(profile.id))
              .ignore();
        default:
          break;
      }
    });

    return MaterialApp.router(
      title: 'LODBOD Shipper',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: ref.watch(routerProvider),
      // Screens without an AppBar inherit this, so the system bars stay
      // readable whatever the phone's own theme is.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemBars,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Shown instead of the app if Firebase can't start, so the problem is
/// explained instead of crashing.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Gap.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BrandMark(size: 64),
                Space.v24,
                Text(
                  "LODBOD couldn't start",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Space.v8,
                Text(
                  'Please check your connection and restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
