import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/account/account_screen.dart';
import '../features/account/edit_profile_screen.dart';
import '../features/account/help_screen.dart';
import '../features/account/legal_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/auth/complete_profile_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/session.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/bids/bid_details_screen.dart';
import '../features/bids/bids_screen.dart';
import '../features/create_shipment/create_shipment_screen.dart';
import '../features/create_shipment/review_screen.dart';
import '../features/create_shipment/shipment_posted_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/shipments/shipment_details_screen.dart';
import '../features/shipments/shipments_screen.dart';
import '../features/shipments/tracking_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Pure redirect rules, kept separate so they're easy to read and test.
String? redirectFor(Session session, String location) {
  if (Routes.publicRoutes.contains(location)) return null;
  final atSignedOut = Routes.signedOutRoutes.contains(location);
  switch (session) {
    case SessionLoading():
      // Stay on auth screens while a sign-in finishes; otherwise show splash.
      return atSignedOut || location == Routes.splash ? null : Routes.splash;
    case SessionSignedOut():
    case SessionWrongRole():
      return atSignedOut ? null : Routes.login;
    case SessionNeedsProfile():
      // Registration creates the profile right after the account; wait on
      // the register screen, otherwise ask the user to complete it.
      return location == Routes.register || location == Routes.completeProfile
          ? null
          : Routes.completeProfile;
    case SessionReady(:final user):
      if (location == Routes.register) {
        return user.emailVerified ? Routes.home : Routes.verifyEmail;
      }
      if (atSignedOut ||
          location == Routes.splash ||
          location == Routes.completeProfile) {
        return Routes.home;
      }
      return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<Session>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);
  ref.onDispose(session.dispose);

  GoRoute pushed(
    String path,
    Widget Function(GoRouterState s) build, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    builder: (context, state) => build(state),
    routes: routes,
  );

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (context, state) =>
        redirectFor(session.value, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.completeProfile,
        builder: (_, _) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: Routes.terms,
        builder: (_, _) => const LegalScreen(doc: LegalDoc.terms),
      ),
      GoRoute(
        path: Routes.privacy,
        builder: (_, _) => const LegalScreen(doc: LegalDoc.privacy),
      ),
      // The posting flow is pushed over whichever tab started it and isn't
      // part of any tab's history, so a tab never reopens a finished flow.
      GoRoute(
        path: Routes.postLoad,
        builder: (_, _) => const CreateShipmentScreen(),
        routes: [
          GoRoute(
            path: 'review',
            builder: (_, _) => const ReviewShipmentScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/posted/:id',
        builder: (_, s) =>
            ShipmentPostedScreen(shipmentId: s.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const DashboardScreen(),
                routes: [
                  pushed('notifications', (_) => const NotificationsScreen()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.shipments,
                builder: (_, _) => const ShipmentsScreen(),
                routes: [
                  pushed(
                    ':id',
                    (s) => ShipmentDetailsScreen(
                      shipmentId: s.pathParameters['id']!,
                    ),
                    routes: [
                      pushed(
                        'track',
                        (s) =>
                            TrackingScreen(shipmentId: s.pathParameters['id']!),
                      ),
                      pushed(
                        'bids',
                        (s) => BidsScreen(shipmentId: s.pathParameters['id']!),
                        routes: [
                          pushed(
                            ':bidId',
                            (s) => BidDetailsScreen(
                              shipmentId: s.pathParameters['id']!,
                              bidId: s.pathParameters['bidId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.analytics,
                builder: (_, _) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (_, _) => const AccountScreen(),
                routes: [
                  pushed('profile', (_) => const EditProfileScreen()),
                  pushed('help', (_) => const HelpScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
