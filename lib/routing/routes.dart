/// Every location in the app. Detail screens are nested under a tab's branch
/// (but drawn full-screen over the shell), so system back returns to that
/// tab. The posting flow is top-level so no tab remembers it once finished.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const completeProfile = '/complete-profile';
  static const verifyEmail = '/verify-email';
  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';

  static const home = '/home';
  static const notifications = '/home/notifications';

  static const postLoad = '/post-load';
  static const postLoadReview = '/post-load/review';
  static String posted(String shipmentId) => '/posted/$shipmentId';

  static const shipments = '/shipments';
  static String shipment(String id) => '/shipments/$id';
  static String track(String id) => '/shipments/$id/track';
  static String bids(String shipmentId) => '/shipments/$shipmentId/bids';
  static String bid(String shipmentId, String bidId) =>
      '/shipments/$shipmentId/bids/$bidId';

  static const analytics = '/analytics';

  static const account = '/account';
  static const editProfile = '/account/profile';
  static const help = '/account/help';

  /// Screens for signed-out users.
  static const signedOutRoutes = {login, register, forgotPassword};

  /// Screens anyone can open regardless of session.
  static const publicRoutes = {terms, privacy};
}
