// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get more => 'More';

  @override
  String get matches => 'Matches';

  @override
  String get shipmentTitle => 'Shipment';

  @override
  String get carrier => 'Carrier';

  @override
  String get arrived => 'Arrived';

  @override
  String get appTitle => 'LODBOD Shipper';

  @override
  String get appShipper => 'SHIPPER';

  @override
  String get appCouldNotStart => 'LODBOD couldn\'t start';

  @override
  String get appCheckConnectionRestart =>
      'Please check your connection and restart the app.';

  @override
  String get appShipperOnly =>
      'This app is for shipper accounts. Carriers use the LODBOD Carrier app.';

  @override
  String appVersionLine(String version) {
    return 'LODBOD Shipper · version $version';
  }

  @override
  String get errRequestLimit =>
      'You have reached the mobile request limit of 3. Please use the LODBOD web platform to create additional requests.';

  @override
  String get errBidAlreadyAccepted =>
      'A bid has already been accepted for this shipment.';

  @override
  String get errInvalidCredentials =>
      'Incorrect phone/email or password. Please try again.';

  @override
  String get errEmailTaken =>
      'An account already exists with this email. Try logging in instead.';

  @override
  String get errPhoneTaken =>
      'This phone number is already linked to another account.';

  @override
  String get errWeakPassword =>
      'Choose a stronger password: at least 8 characters with a number.';

  @override
  String get errTooManyAttempts =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get errAccountDisabled =>
      'This account has been disabled. Contact LODBOD support.';

  @override
  String get errSignInUnavailable =>
      'Sign-in isn\'t available right now. Please try again later.';

  @override
  String get errOffline =>
      'Couldn\'t reach LODBOD. Check your connection and try again. Retrying is safe and won\'t create duplicates.';

  @override
  String get errNoAccess =>
      'You don\'t have access to this. Try signing out and in again.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get errRecordGone => 'That record no longer exists.';

  @override
  String get errShipmentGone => 'This shipment no longer exists.';

  @override
  String get errBidGone => 'This bid is no longer available.';

  @override
  String errShipmentNotAcceptingBids(String status) {
    return 'This shipment is no longer accepting bids ($status).';
  }

  @override
  String get errPickupPassedRepost =>
      'The pickup time for this request has passed. Post it again with a new date.';

  @override
  String get errOnlyAwaitingBidsReceive =>
      'Only shipments awaiting bids can receive bids.';

  @override
  String get errAlreadyHasBids => 'This shipment already has bids.';

  @override
  String get errAccountNotSetUp =>
      'Your account is not set up yet. Sign out and sign in again.';

  @override
  String errCannotTransition(String to, String status) {
    return 'This shipment can\'t be $to because it is $status.';
  }

  @override
  String errNoCarrierUpdate(String status) {
    return 'No carrier update applies to \"$status\".';
  }

  @override
  String get errUpdatedElsewhere =>
      'This shipment was updated elsewhere. Review its latest status.';

  @override
  String errCouldNotOpenDialer(String phone) {
    return 'Couldn\'t open the phone app. The number is +977 $phone.';
  }

  @override
  String get errCouldNotLoad => 'Couldn\'t load this';

  @override
  String get unknownStatus => 'unknown status';

  @override
  String get unknownState => 'in an unknown state';

  @override
  String get timelinePosted => 'Request posted from the mobile app';

  @override
  String get timelineCancelledByShipper => 'Cancelled by shipper';

  @override
  String get timelineExpired =>
      'Expired: the pickup time passed without a booking';

  @override
  String timelineBidAccepted(String carrier) {
    return 'Bid from $carrier accepted';
  }

  @override
  String get timelineScheduledSim => 'Carrier scheduled the pickup (simulated)';

  @override
  String get timelinePickedUpSim => 'Cargo picked up (simulated)';

  @override
  String get timelineDeliveredSim => 'Delivered at destination (simulated)';

  @override
  String vRequired(String label) {
    return '$label is required';
  }

  @override
  String get vEmailRequired => 'Email is required';

  @override
  String get vEmailInvalid => 'Enter a valid email, e.g. name@company.com';

  @override
  String get vPhoneRequired => 'Phone number is required';

  @override
  String get vPhoneInvalid =>
      'Enter a 10-digit mobile number starting with 97 or 98';

  @override
  String get vPasswordRequired => 'Password is required';

  @override
  String get vPasswordMin => 'Password must be at least 8 characters';

  @override
  String get vNameRequired => 'Full name is required';

  @override
  String get vNameInvalid => 'Enter your full name';

  @override
  String get vPasswordUseEight => 'Use at least 8 characters';

  @override
  String get vPasswordLetterNumber =>
      'Include at least one letter and one number';

  @override
  String get vIdentifierRequired => 'Enter your email or phone number';

  @override
  String get vPickupRequired => 'Pickup location is required';

  @override
  String get vPickupInvalid => 'Enter a valid pickup location';

  @override
  String get vDestinationRequired => 'Destination is required';

  @override
  String get vDestinationInvalid => 'Enter a valid destination';

  @override
  String get vDestinationSame =>
      'Destination must be different from the pickup location';

  @override
  String get vPickupDateRequired => 'Choose a pickup date';

  @override
  String get vPickupDatePast => 'Pickup date can\'t be in the past';

  @override
  String vPickupDateTooFar(int days) {
    return 'Pickup must be within the next $days days';
  }

  @override
  String get vPickupTimeRequired => 'Choose a pickup time';

  @override
  String get vPickupTimePast => 'Pickup time can\'t be in the past';

  @override
  String get vCategoryRequired => 'Choose a cargo category';

  @override
  String get vDescriptionRequired => 'Describe the cargo, e.g. \"Steel pipes\"';

  @override
  String get vDescriptionTooLong => 'Keep the description under 80 characters';

  @override
  String get vWeightRequired => 'Weight is required';

  @override
  String get vWeightNumber => 'Enter weight as a number';

  @override
  String get vWeightPositive => 'Weight must be greater than 0';

  @override
  String vWeightMax(int tonnes) {
    return 'Maximum $tonnes t per request';
  }

  @override
  String get vVehicleRequired => 'Choose a vehicle type';

  @override
  String get vFareWhole => 'Enter the fare in whole rupees';

  @override
  String get vFarePositive => 'Fare must be greater than 0';

  @override
  String get vFareTooHigh => 'That fare looks too high';

  @override
  String get vContactNameTooLong => 'Keep the name under 60 characters';

  @override
  String get vNotesTooLong => 'Keep notes under 300 characters';

  @override
  String get fmtJustNow => 'Just now';

  @override
  String fmtMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String fmtHoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String fmtDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String fmtDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get fmtMonthsShort =>
      'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get fmtWeekdaysShort => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get statusAwaitingBids => 'Awaiting bids';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusInTransit => 'In transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusExpired => 'Expired';

  @override
  String statusLabelA11y(String label) {
    return 'Status: $label';
  }

  @override
  String get bidPending => 'Open';

  @override
  String get bidAccepted => 'Accepted';

  @override
  String get bidNotSelected => 'Not selected';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterClosed => 'Cancelled / expired';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortPickupDate => 'Pickup date';

  @override
  String get sortStatus => 'Status';

  @override
  String get cargoCement => 'Cement';

  @override
  String get cargoSteel => 'Steel';

  @override
  String get cargoConstruction => 'Construction material';

  @override
  String get cargoFoodGrains => 'Food grains';

  @override
  String get cargoFmcg => 'FMCG';

  @override
  String get cargoFurniture => 'Furniture';

  @override
  String get cargoElectronics => 'Electronics';

  @override
  String get cargoOther => 'Other';

  @override
  String get vehicleOpen => 'Open truck';

  @override
  String get vehicleClosed => 'Closed truck';

  @override
  String get vehicleTrailer => 'Trailer';

  @override
  String get vehicleContainer => 'Container';

  @override
  String get vehicleTanker => 'Tanker';

  @override
  String get vehicleTipper => 'Tipper';

  @override
  String get vehicleMini => 'Mini truck';

  @override
  String get unitTonnes => 'Tonnes';

  @override
  String get unitKilograms => 'Kilograms';

  @override
  String get unitTonneSymbol => 't';

  @override
  String get unitKgSymbol => 'kg';

  @override
  String get stepRoute => 'Route';

  @override
  String get stepCargo => 'Cargo';

  @override
  String get stepVehicle => 'Vehicle';

  @override
  String get stepReview => 'Review';

  @override
  String get stepRouteTitle => 'Route & schedule';

  @override
  String get stepCargoTitle => 'Cargo details';

  @override
  String get stepVehicleTitle => 'Vehicle & contact';

  @override
  String stepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String stepOfA11y(int n, int total, String title) {
    return 'Step $n of $total: $title';
  }

  @override
  String get completed => 'completed';

  @override
  String get period30 => '30 days';

  @override
  String get period90 => '90 days';

  @override
  String get periodAll => 'All time';

  @override
  String get navHome => 'Home';

  @override
  String get navShipments => 'Shipments';

  @override
  String get navPostLoad => 'Post Load';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navAccount => 'Account';

  @override
  String get navPostNewLoad => 'Post a new load';

  @override
  String navNeedAttention(String label, int n) {
    return '$label, $n need attention';
  }

  @override
  String badgeNew(String label, int n) {
    return '$label, $n new';
  }

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get actionGoBack => 'Go back';

  @override
  String get actionGotIt => 'Got it';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionLogIn => 'Log in';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get actionSaveDraft => 'Save draft';

  @override
  String get actionPostLoad => 'Post load';

  @override
  String get actionPostALoad => 'Post a load';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDetails => 'Details';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionKeepIt => 'Keep it';

  @override
  String get actionCancelShipment => 'Cancel shipment';

  @override
  String get actionCancelRequest => 'Cancel request';

  @override
  String get actionViewBids => 'View bids';

  @override
  String get actionTrackShipment => 'Track shipment';

  @override
  String get actionPostSimilar => 'Post a similar load';

  @override
  String get actionCopyReference => 'Copy reference';

  @override
  String get actionMoreActions => 'More actions';

  @override
  String get actionCompareBids => 'Compare bids';

  @override
  String get actionHowItWorks => 'How it works';

  @override
  String get actionManageRequests => 'Manage requests';

  @override
  String get actionViewMyRequests => 'View my requests';

  @override
  String get actionBackToLogIn => 'Back to log in';

  @override
  String get actionResendEmail => 'Resend email';

  @override
  String get actionSkipForNow => 'Skip for now';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get actionClearSearchFilters => 'Clear search and filters';

  @override
  String get actionStartOver => 'Start over';

  @override
  String get actionClearForm => 'Clear form';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get actionReviewRequest => 'Review request';

  @override
  String actionContinueTo(String step) {
    return 'Continue to $step';
  }

  @override
  String get optional => '(optional)';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldEmailOrPhone => 'Email or phone number';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldCompany => 'Company name';

  @override
  String get hintName => 'e.g. Aarav Shrestha';

  @override
  String get hintCompany => 'e.g. Himal Traders Pvt. Ltd.';

  @override
  String get hintEmail => 'you@company.com';

  @override
  String get hintEmailOrPhone => 'you@company.com or 98XXXXXXXX';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordHint =>
      'At least 8 characters, with a letter and a number';

  @override
  String get passwordWeak => 'Weak password';

  @override
  String get passwordGood => 'Good password';

  @override
  String get passwordStrong => 'Strong password';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to manage your loads and shipments.';

  @override
  String get loginForgot => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get legalByContinuing => 'By continuing you agree to the ';

  @override
  String get legalIAgree => 'I agree to the ';

  @override
  String get legalAnd => ' and ';

  @override
  String get legalTerms => 'Terms of Service';

  @override
  String get legalPrivacy => 'Privacy Policy';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Post loads and compare carrier bids in minutes.';

  @override
  String get registerVerifyHelper => 'We\'ll send a verification link here.';

  @override
  String get registerAcceptTerms =>
      'Please accept the terms to create an account';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle =>
      'Enter the email or phone number on your account and we will email you a link to set a new password.';

  @override
  String get forgotSend => 'Send reset link';

  @override
  String get forgotRemembered => 'Remembered it?';

  @override
  String get forgotSentTitle => 'Check your email';

  @override
  String forgotSentBody(String identifier) {
    return 'If an account exists for $identifier, a link to reset your password is on its way. It may take a minute; if it doesn\'t arrive, check your spam folder.';
  }

  @override
  String get forgotUseDifferent => 'Use a different email or phone';

  @override
  String get verifyTitle => 'Verify your email';

  @override
  String get verifySentTo => 'We sent a verification link to ';

  @override
  String get verifyOpenIt => '. Open it to activate your account.';

  @override
  String get verifyDone => 'I\'ve verified my email';

  @override
  String get verifyDidntGet => 'Didn\'t get it?';

  @override
  String verifyResendIn(String seconds) {
    return 'Resend in 0:$seconds';
  }

  @override
  String get verifySuccess => 'Email verified. Welcome to LODBOD!';

  @override
  String get verifyNotYet =>
      'We couldn\'t confirm it yet. Open the link in the email, then try again.';

  @override
  String get verifyResent => 'Verification email sent again.';

  @override
  String get verifyLinkSent => 'Verification link sent. Check your inbox.';

  @override
  String get completeTitle => 'Finish setting up';

  @override
  String get completeSubtitle =>
      'Tell us who you are so carriers know who they are working with.';

  @override
  String get splashChecking => 'Checking your session…';

  @override
  String get splashLoadFailed => 'We couldn\'t load your account';

  @override
  String get homeGoodMorning => 'Good morning,';

  @override
  String get homeGoodAfternoon => 'Good afternoon,';

  @override
  String get homeGoodEvening => 'Good evening,';

  @override
  String get homeShipNew => 'Ship something new';

  @override
  String get homeRequestsUsed => 'Mobile requests used: ';

  @override
  String homeUsedOf(int used, int limit) {
    return '$used of $limit';
  }

  @override
  String homeUsedOfInUse(int used, int limit) {
    return '$used of $limit in use';
  }

  @override
  String homeRequestsInUseA11y(int used, int limit) {
    return '$used of $limit mobile requests in use';
  }

  @override
  String homeAllInUse(int limit) {
    return 'All $limit are in use. Finish or cancel one to post a new load. ';
  }

  @override
  String get homeNeedsAction => 'Needs your action';

  @override
  String homeBidsOn(int n, String reference) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bids on $reference',
      one: '1 bid on $reference',
    );
    return '$_temp0';
  }

  @override
  String homeRoutePickup(String route, String date) {
    return '$route · Pickup $date';
  }

  @override
  String get homeOnTheRoad => 'On the road';

  @override
  String get homeNextPickup => 'Next pickup';

  @override
  String get homeOtherShipments => 'Other shipments';

  @override
  String homeSeeAllN(int n) {
    return 'See all $n shipments';
  }

  @override
  String homeStatA11y(int count, String label) {
    return '$count $label. Show these shipments';
  }

  @override
  String homeLeft(String place) {
    return 'Left $place';
  }

  @override
  String homePassed(String place) {
    return 'Passed $place';
  }

  @override
  String homeKmLeft(String where, int km) {
    return '$where · $km km left';
  }

  @override
  String get runningLate => 'Running late';

  @override
  String etaTime(String time) {
    return 'ETA $time';
  }

  @override
  String get simulatedTracking => 'Simulated tracking';

  @override
  String get homeSamplesAdded => 'Sample shipments added. Have a look around!';

  @override
  String get homeSamplesFailed => 'Couldn\'t add sample shipments. Try again.';

  @override
  String get homeWelcome => 'Welcome to LODBOD';

  @override
  String get homeWelcomeBody =>
      'Move goods across Nepal with trusted carriers. Here is how it works:';

  @override
  String get homeStep1 => 'Post a load';

  @override
  String get homeStep1Body => 'Route, cargo and truck in under a minute.';

  @override
  String get homeStep2 => 'Compare bids';

  @override
  String get homeStep2Body => 'Verified carriers send offers you can compare.';

  @override
  String get homeStep3 => 'Track delivery';

  @override
  String get homeStep3Body => 'Follow every step until it is delivered.';

  @override
  String get homePostFirst => 'Post your first load';

  @override
  String get homeExploreSamples => 'Explore with sample shipments';

  @override
  String get homeLoading => 'Loading your shipments';

  @override
  String get shipmentsSort => 'Sort shipments';

  @override
  String shipmentsSortBy(String sort) {
    return 'Sort: $sort';
  }

  @override
  String get shipmentsSearchHint => 'Search reference, route or cargo';

  @override
  String shipmentsCount(int n, String sort) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n shipments',
      one: '1 shipment',
    );
    return '$_temp0 · $sort';
  }

  @override
  String get shipmentsNoMatch => 'No matching shipments';

  @override
  String get shipmentsNoMatchBody =>
      'Try a different reference, city or status.';

  @override
  String get shipmentsEmpty => 'No shipments yet';

  @override
  String get shipmentsEmptyBody =>
      'Post a load and carriers will start bidding on it.';

  @override
  String cardA11y(String reference, String status, String from, String to) {
    return '$reference, $status, $from to $to';
  }

  @override
  String cardPosted(String when) {
    return 'Posted $when';
  }

  @override
  String get cardWaitingForBids => 'Waiting for bids';

  @override
  String cardBids(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bids',
      one: '1 bid',
    );
    return '$_temp0';
  }

  @override
  String get cardFarePending => 'Fare pending';

  @override
  String cardBudget(String amount) {
    return 'Budget $amount';
  }

  @override
  String cardStatusWhen(String status, String when) {
    return '$status $when';
  }

  @override
  String cardDeliveredOn(String date) {
    return 'Delivered $date';
  }

  @override
  String get cardCarrierAssigned => 'Carrier assigned';

  @override
  String cardPickupAt(String time) {
    return 'Pickup $time';
  }

  @override
  String get onTheWay => 'On the way';

  @override
  String cardPickedUp(String when) {
    return 'Picked up $when';
  }

  @override
  String routeAtoB(String from, String to) {
    return '$from to $to';
  }

  @override
  String get timelinePostedStep => 'Posted';

  @override
  String get timelineBookedStep => 'Booked';

  @override
  String timelineA11y(String status) {
    return 'Shipment $status';
  }

  @override
  String timelineStepA11y(int n, String label) {
    return 'Step $n of 5: $label';
  }

  @override
  String detailsPosted(String date) {
    return 'Posted $date';
  }

  @override
  String get detailsNotFound => 'Shipment not found';

  @override
  String get detailsNotFoundBody =>
      'It may have been removed. Go back to your shipments.';

  @override
  String get detailsRemoved => 'It may have been removed.';

  @override
  String detailsPickupLine(String when) {
    return 'Pickup · $when';
  }

  @override
  String detailsDeliveredLine(String when) {
    return 'Delivered · $when';
  }

  @override
  String detailsEtaLine(String when) {
    return 'Estimated arrival · $when';
  }

  @override
  String get detailsSection => 'Shipment details';

  @override
  String get detailsCargo => 'Cargo';

  @override
  String get detailsWeight => 'Weight';

  @override
  String get detailsVehicle => 'Vehicle';

  @override
  String get detailsYourBudget => 'Your budget';

  @override
  String get openToBids => 'Open to bids';

  @override
  String get detailsContactSection => 'Pickup contact & notes';

  @override
  String get detailsContact => 'Contact';

  @override
  String get detailsPhone => 'Phone';

  @override
  String get detailsNotes => 'Notes';

  @override
  String detailsCall(String name) {
    return 'Call $name';
  }

  @override
  String get contact => 'contact';

  @override
  String get detailsActivity => 'Activity';

  @override
  String get detailsDropOff => 'Drop-off';

  @override
  String detailsCarriersHaveBid(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n carriers have bid',
      one: '1 carrier has bid',
    );
    return '$_temp0';
  }

  @override
  String get detailsFindingCarriers => 'Finding carriers…';

  @override
  String get detailsCompareBody =>
      'Compare price, rating and delivery time, then book one.';

  @override
  String get detailsVisibleBody =>
      'Your load is visible to carriers. Bids usually arrive within minutes.';

  @override
  String get detailsCancelledTitle => 'This request was cancelled';

  @override
  String get detailsExpiredTitle => 'This request expired';

  @override
  String get detailsClosedBody =>
      'It no longer counts toward your mobile request limit. You can post it again in a tap.';

  @override
  String get detailsAgreedFare => 'Agreed fare';

  @override
  String get detailsEstimatedArrival => 'Estimated arrival';

  @override
  String detailsKmToGo(String where, int km) {
    return '$where · $km km to go · simulated';
  }

  @override
  String get detailsReplaceTitle => 'Replace your unfinished load?';

  @override
  String detailsReplaceBody(String reference) {
    return 'You have a load you were still filling in. Starting from $reference will replace it.';
  }

  @override
  String get detailsReplaceIt => 'Replace it';

  @override
  String detailsCompareN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Compare $n bids',
      one: 'Compare 1 bid',
    );
    return '$_temp0';
  }

  @override
  String detailsCancelTitle(String reference) {
    return 'Cancel $reference?';
  }

  @override
  String get detailsCancelOpenBody =>
      'Carriers will no longer be able to bid, and any open bids will be declined.';

  @override
  String detailsCancelBookedBody(String carrier) {
    return 'Your booking with $carrier will be cancelled. This frees up one of your mobile requests.';
  }

  @override
  String get theCarrier => 'the carrier';

  @override
  String detailsCancelled(String reference) {
    return '$reference cancelled.';
  }

  @override
  String detailsCopied(String reference) {
    return '$reference copied';
  }

  @override
  String get simCarrierUpdate => 'Simulate carrier update';

  @override
  String simCarrierUpdateBody(String reference, String status) {
    return 'Mark $reference as \"$status\". In the live service this update comes from the carrier.';
  }

  @override
  String simMark(String status) {
    return 'Mark $status';
  }

  @override
  String simNowStatus(String reference, String status) {
    return '$reference is now $status.';
  }

  @override
  String simMenuMark(String status) {
    return 'Simulate: mark $status';
  }

  @override
  String get simDemoCarrierUpdate => 'Demo carrier update';

  @override
  String get simBidsNow => 'Simulate: bids arrive now';

  @override
  String get simDemoBids => 'Demo carrier bids';

  @override
  String get simBidsNowDemo => 'Simulate bids now (demo)';

  @override
  String get bidsTitle => 'Bids';

  @override
  String bidsRefRoute(String reference, String route) {
    return '$reference · $route';
  }

  @override
  String bidsCargoWeight(String cargo, String weight) {
    return '$cargo · $weight';
  }

  @override
  String bidsPickupVehicle(String when, String vehicle) {
    return 'Pickup $when · $vehicle';
  }

  @override
  String bidsBudgetLine(String amount) {
    return 'Budget $amount';
  }

  @override
  String bidsBookedWith(String carrier) {
    return 'Booked with $carrier';
  }

  @override
  String bidsBookedBody(String fare, String reference, String status) {
    return '$fare · $reference is $status.';
  }

  @override
  String bidsClosedBody(String status) {
    return 'This shipment is $status and no longer accepting bids.';
  }

  @override
  String bidsOffers(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n offers',
      one: '1 offer',
    );
    return '$_temp0';
  }

  @override
  String get bidsSortBy => 'Sort by';

  @override
  String get bidsSortNewest => 'Newest';

  @override
  String get bidsSortPrice => 'Price';

  @override
  String get bidsSortRating => 'Rating';

  @override
  String get bidsSortFastest => 'Fastest';

  @override
  String get bidsWaiting => 'Waiting for carriers';

  @override
  String get bidsNone => 'No bids';

  @override
  String get bidsWaitingBody =>
      'Your load is visible to carriers. Offers usually arrive within minutes, and we will notify you.';

  @override
  String get bidsNoneBody => 'This shipment did not receive any bids.';

  @override
  String bidUnder(String amount) {
    return '$amount under';
  }

  @override
  String bidOver(String amount) {
    return '$amount over';
  }

  @override
  String bidA11y(String carrier, String fare, String days, String rating) {
    return '$carrier, $fare, $days, rated $rating';
  }

  @override
  String get bidDelivery => 'Delivery';

  @override
  String get bidVehicle => 'Vehicle';

  @override
  String bidBy(String date) {
    return 'by $date';
  }

  @override
  String bidReceived(String when) {
    return 'Received $when';
  }

  @override
  String bidRatedA11y(String rating, int trips) {
    return 'Rated $rating out of 5 from $trips trips';
  }

  @override
  String bidTrips(int trips) {
    return '  ·  $trips trips';
  }

  @override
  String get offerTitle => 'Offer details';

  @override
  String get offerNotFound => 'Bid not found';

  @override
  String get offerNotFoundBody => 'This bid may have been withdrawn.';

  @override
  String get offerBooked => 'You booked this carrier';

  @override
  String offerBookedBody(String reference, String status, String carrier) {
    return '$reference is $status with $carrier';
  }

  @override
  String offerNotSelectedBody(String reference) {
    return 'Not selected: you booked another carrier for $reference.';
  }

  @override
  String offerClosedBody(String reference, String status) {
    return '$reference is $status, so this offer can no longer be accepted.';
  }

  @override
  String get offerFare => 'Offered fare';

  @override
  String get offerSection => 'Offer';

  @override
  String offerAfterPickup(String days) {
    return '$days after pickup';
  }

  @override
  String get offerArrivesBy => 'Arrives by';

  @override
  String offerEstimate(String date) {
    return '$date (estimate)';
  }

  @override
  String get offerReceived => 'Received';

  @override
  String get offerNote => 'Note';

  @override
  String get offerYourLoad => 'Your load';

  @override
  String get offerPickup => 'Pickup';

  @override
  String get offerRequested => 'Requested';

  @override
  String get offerMatchesBudget => 'Matches your budget';

  @override
  String offerDiffBudget(String amount, String direction) {
    return '$amount $direction your budget';
  }

  @override
  String get over => 'above';

  @override
  String get under => 'below';

  @override
  String get offerConfirmNote => 'You confirm before anything is booked';

  @override
  String acceptFor(String amount) {
    return 'Accept for $amount';
  }

  @override
  String acceptTitle(String carrier) {
    return 'Book $carrier?';
  }

  @override
  String acceptBody(String reference, String others) {
    return 'This confirms $reference with this carrier. ${others}This can\'t be undone from the app.';
  }

  @override
  String acceptOthersDeclined(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'The other $n offers will be declined. ',
      one: 'The other offer will be declined. ',
    );
    return '$_temp0';
  }

  @override
  String get acceptRoute => 'Route';

  @override
  String get acceptFare => 'Fare';

  @override
  String acceptAbout(String days) {
    return 'About $days';
  }

  @override
  String acceptBooked(String reference, String carrier) {
    return 'Booked! $reference is confirmed with $carrier';
  }

  @override
  String acceptFailed(String message) {
    return '$message The offer hasn\'t been accepted yet.';
  }

  @override
  String get postTitle => 'Post a load';

  @override
  String postPostingAs(String company) {
    return 'Posting as $company';
  }

  @override
  String get postResumed => 'Picked up where you left off';

  @override
  String get postDraftSaved =>
      'Draft saved. Finish it any time from Post Load.';

  @override
  String get postDraftSavedShort => 'Draft saved';

  @override
  String get postStartOverTitle => 'Start over?';

  @override
  String get postStartOverBody =>
      'Everything you entered for this load will be cleared, including the saved draft.';

  @override
  String get postAllInUse => 'All 3 mobile requests are in use';

  @override
  String get postAllInUseBody =>
      'Prepare it now and post it once one of your requests is delivered or cancelled.';

  @override
  String get postAllInUseReviewBody =>
      'You can post this load once one of your requests is delivered or cancelled.';

  @override
  String postDoneA11y(String title, String summary) {
    return '$title: $summary. Edit';
  }

  @override
  String get postPickupDate => 'Pickup date';

  @override
  String get postPickupTime => 'Pickup time';

  @override
  String get postTimePassed =>
      'That time has already passed today. Choose a later time.';

  @override
  String get postToday => 'Today';

  @override
  String get postTomorrow => 'Tomorrow';

  @override
  String get postPlus2Days => '+2 days';

  @override
  String get postPickDate => 'Pick date';

  @override
  String get postPickupCity => 'Pickup city';

  @override
  String get postDestinationCity => 'Destination city';

  @override
  String get postSwap => 'Swap pickup and destination';

  @override
  String get postRecent => 'RECENT';

  @override
  String get postMorning => 'Morning';

  @override
  String get postMidday => 'Midday';

  @override
  String get postAfternoon => 'Afternoon';

  @override
  String get postEvening => 'Evening';

  @override
  String get postExact => 'Exact';

  @override
  String get postPickTime => 'pick time';

  @override
  String get postSlotsPassedAll =>
      'Today\'s usual slots have passed. Pick an exact time or another day.';

  @override
  String get postSlotsPassedSome =>
      'Earlier times today have passed. Pick a later slot or an exact time.';

  @override
  String get postMaterial => 'Material';

  @override
  String get postWhatShipping => 'What are you shipping?';

  @override
  String get postWhatShippingHint => 'e.g. 240 cement bags, steel pipes';

  @override
  String get postTotalWeight => 'Total weight';

  @override
  String get postWeightHint => 'e.g. 12';

  @override
  String get postVehicleType => 'Vehicle type';

  @override
  String get postYourBudget => 'Your budget';

  @override
  String get postBudgetHelper =>
      'Carriers see this as a guide and can bid above or below it.';

  @override
  String get postPickupContact => 'Pickup contact';

  @override
  String get postContactHint => 'Name at the pickup point';

  @override
  String get postNotes => 'Notes for carriers';

  @override
  String get postNotesHint => 'Loading instructions, packaging, gate timings…';

  @override
  String get reviewSubtitle => 'Check everything before posting';

  @override
  String get reviewNeedsAttention =>
      'A few details need attention before posting.';

  @override
  String get reviewLimitReached => 'Request limit reached';

  @override
  String get reviewCouldNotPost => 'Couldn\'t post your load';

  @override
  String reviewDetailsSaved(String message) {
    return '$message Your details are saved.';
  }

  @override
  String get reviewMaterial => 'Material';

  @override
  String get reviewDescription => 'Description';

  @override
  String get reviewWeight => 'Weight';

  @override
  String get reviewVehicle => 'Vehicle';

  @override
  String get reviewBudget => 'Budget';

  @override
  String get reviewContact => 'Contact';

  @override
  String get reviewPhone => 'Phone';

  @override
  String get reviewNotes => 'Notes';

  @override
  String reviewUsesRequest(int n, int limit) {
    return 'Posting uses mobile request $n of $limit. Carriers can start bidding straight away.';
  }

  @override
  String get postedTitle => 'Load posted';

  @override
  String get postedLive => 'Your request is live.';

  @override
  String postedLiveBody(String reference) {
    return '$reference is live. We\'ll let you know as soon as the first bid arrives.';
  }

  @override
  String get postedRequestCreated => 'REQUEST CREATED';

  @override
  String get postedPickup => 'Pickup';

  @override
  String get postedCargo => 'Cargo';

  @override
  String get postedVehicle => 'Vehicle';

  @override
  String get postedViewRequest => 'View request & bids';

  @override
  String get postedPostAnother => 'Post another load';

  @override
  String get limitTitleReached => 'Request limit reached';

  @override
  String get limitTitle => 'Mobile request limit';

  @override
  String limitBody(int max, int used, int limit) {
    return 'You can have up to $max open requests from the mobile app at a time. You are using $used of $limit.';
  }

  @override
  String get limitDetailsSaved =>
      'Your details are saved. You can submit as soon as a request is delivered, cancelled or expires.';

  @override
  String get limitCanPost =>
      'You can post a new load as soon as a request is delivered, cancelled or expires.';

  @override
  String get limitCounts => 'Counts toward the limit';

  @override
  String get limitDoesNotCount => 'Doesn\'t count';

  @override
  String notifNewBid(String reference) {
    return 'New bid on $reference';
  }

  @override
  String notifNewBidBody(String carrier, String fare, String days) {
    return '$carrier offered $fare · $days delivery';
  }

  @override
  String notifLive(String reference) {
    return '$reference is live';
  }

  @override
  String notifLiveBody(String route) {
    return '$route · carriers can now bid';
  }

  @override
  String notifConfirmed(String reference) {
    return '$reference confirmed';
  }

  @override
  String get notifConfirmedBody => 'A carrier has been booked';

  @override
  String notifScheduled(String reference) {
    return 'Pickup scheduled for $reference';
  }

  @override
  String notifScheduledBody(String carrier, String when) {
    return '$carrier · $when';
  }

  @override
  String notifOnTheWay(String reference) {
    return '$reference is on the way';
  }

  @override
  String notifPickedUpIn(String place) {
    return 'Picked up in $place';
  }

  @override
  String notifDelivered(String reference) {
    return '$reference delivered';
  }

  @override
  String notifDeliveredIn(String place) {
    return 'Delivered in $place';
  }

  @override
  String notifCancelled(String reference) {
    return '$reference cancelled';
  }

  @override
  String notifExpired(String reference) {
    return '$reference expired';
  }

  @override
  String get notifExpiredBody => 'No carrier was booked before pickup';

  @override
  String notifNewBidsOn(int n, String reference) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n new bids on $reference',
      one: 'New bid on $reference',
    );
    return '$_temp0';
  }

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifToday => 'Today';

  @override
  String get notifYesterday => 'Yesterday';

  @override
  String get notifEarlier => 'Earlier';

  @override
  String get notifCaughtUp => 'You\'re all caught up';

  @override
  String get notifCaughtUpBody =>
      'Bids, bookings and delivery updates will show up here.';

  @override
  String get notifView => 'View';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsSubtitle => 'How your shipping is going';

  @override
  String get analyticsNoData => 'No data yet';

  @override
  String get analyticsNothingPeriod => 'Nothing in this period';

  @override
  String get analyticsNoDataBody => 'Your stats appear once you post a load.';

  @override
  String get analyticsNothingPeriodBody =>
      'Try a longer period to see your activity.';

  @override
  String analyticsBookedSpend(String period) {
    return 'Booked spend · $period';
  }

  @override
  String analyticsBookedLoads(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n booked loads',
      one: '1 booked load',
    );
    return '$_temp0';
  }

  @override
  String analyticsAvgPerLoad(String amount) {
    return ' · avg $amount per load';
  }

  @override
  String get analyticsLoadsPosted => 'Loads posted';

  @override
  String analyticsOpenNow(int n) {
    return '$n open now';
  }

  @override
  String get analyticsDelivered => 'Delivered';

  @override
  String analyticsTonnesMoved(String t) {
    return '$t t moved';
  }

  @override
  String get analyticsBidsReceived => 'Bids received';

  @override
  String analyticsAcrossLoads(int n) {
    return 'across $n loads';
  }

  @override
  String get analyticsAvgBids => 'Avg. bids per load';

  @override
  String get analyticsPerPostedLoad => 'per posted load';

  @override
  String get analyticsByStatus => 'Shipments by status';

  @override
  String get analyticsTopRoutes => 'Top routes';

  @override
  String analyticsLoads(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n loads',
      one: '1 load',
    );
    return '$_temp0';
  }

  @override
  String analyticsStatusA11y(String status, int count) {
    return '$status: $count';
  }

  @override
  String get accountTitle => 'Account';

  @override
  String accountShipperLine(String company) {
    return '$company · Shipper';
  }

  @override
  String get accountSection => 'Account';

  @override
  String get accountProfile => 'Profile & company';

  @override
  String get accountVerify => 'Verify';

  @override
  String get accountVerified => 'Verified';

  @override
  String get accountSending => 'Sending…';

  @override
  String get accountMobileRequests => 'Mobile requests';

  @override
  String get accountPreferences => 'Preferences';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountAppearance => 'Appearance';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountNewBidAlerts => 'New bid alerts';

  @override
  String get accountDeliveryUpdates => 'Delivery updates';

  @override
  String get accountSupport => 'Support & feedback';

  @override
  String get accountHelpCenter => 'Help center';

  @override
  String get accountSendFeedback => 'Send feedback';

  @override
  String get accountLegal => 'Legal';

  @override
  String get accountDemo => 'Demo';

  @override
  String get accountLoadSamples => 'Load sample shipments';

  @override
  String get accountLoadSamplesTitle => 'Load sample shipments?';

  @override
  String get accountLoadSamplesBody =>
      'Your shipments and bids will be replaced with a sample set (LOD-1001 to LOD-1004) so you can explore every feature. New references continue from the last one used.';

  @override
  String get accountLoadSamplesConfirm => 'Load samples';

  @override
  String get accountSamplesLoaded => 'Sample shipments loaded.';

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountSignOutDraft =>
      'Your unfinished load will be kept as a saved draft for next time.';

  @override
  String get accountSignOutBody =>
      'You\'ll need to log in again to manage your shipments.';

  @override
  String get individualShipper => 'Individual shipper';

  @override
  String get profileNote =>
      'Carriers see your name and company on the loads you post.';

  @override
  String get profilePhoneHelper => 'You can log in with this number.';

  @override
  String get profileEmailHelper =>
      'Your sign-in email. Contact support to change it.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get feedbackMin => 'Tell us a little more (at least 10 characters).';

  @override
  String get feedbackSent => 'Thanks! Your feedback has been sent.';

  @override
  String get feedbackSubtitle => 'We read every message.';

  @override
  String get feedbackProblem => 'Problem';

  @override
  String get feedbackIdea => 'Idea';

  @override
  String get feedbackQuestion => 'Question';

  @override
  String get feedbackProblemHint => 'What happened, and what did you expect?';

  @override
  String get feedbackIdeaHint => 'What would make LODBOD better for you?';

  @override
  String get feedbackQuestionHint => 'What would you like to know?';

  @override
  String get feedbackSend => 'Send';

  @override
  String get helpFaq => 'Frequently asked';

  @override
  String get helpQ1 => 'How do I post a load?';

  @override
  String get helpA1 =>
      'Tap Post Load, enter the route and pickup time, describe the cargo and choose a vehicle. Review it and post. Carriers can bid straight away.';

  @override
  String get helpQ2 => 'Why can I only have 3 open requests?';

  @override
  String helpA2(int max) {
    return 'From the mobile app you can have up to $max requests that are awaiting bids, confirmed, scheduled or in transit at once. Delivered, cancelled and expired requests free up a slot. For more volume, use the LODBOD web platform.';
  }

  @override
  String get helpQ3 => 'How do I choose a bid?';

  @override
  String get helpA3 =>
      'Open your shipment and tap Compare bids. You can sort by price, rating or delivery time and open any offer for details. Nothing is booked until you confirm.';

  @override
  String get helpQ4 => 'Can I cancel a shipment?';

  @override
  String get helpA4 =>
      'Yes, until pickup. Open the shipment, tap the ⋮ menu and choose Cancel shipment. Open bids are declined.';

  @override
  String get helpQ5 => 'Where is my truck?';

  @override
  String get helpA5 =>
      'Booked shipments have a Track shipment screen with the route, checkpoints and estimated arrival. In this version tracking is simulated from the schedule.';

  @override
  String get helpQ6 => 'Will I lose an unfinished load?';

  @override
  String get helpA6 =>
      'No. Drafts are saved to your account when you close Post Load or tap Save draft, so you can finish them later.';

  @override
  String get helpStillNeed => 'Still need help?';

  @override
  String get helpStillNeedBody =>
      'Send us a message and the team will get back to you.';

  @override
  String get helpMessage => 'Message';

  @override
  String get legalSummaryUpdated => 'Summary · updated 8 Nov 2026';

  @override
  String get legalT1 => 'Using LODBOD';

  @override
  String get legalT1Body =>
      'LODBOD connects shippers with independent carriers. You must provide accurate details about your loads, routes and contacts.';

  @override
  String get legalT2 => 'Posting loads';

  @override
  String get legalT2Body =>
      'A posted load is an invitation for carriers to bid. Mobile accounts can have up to 3 open requests at a time; additional requests can be created on the LODBOD web platform.';

  @override
  String get legalT3 => 'Bids and bookings';

  @override
  String get legalT3Body =>
      'A booking is made only when you accept a bid and confirm it. Accepting one bid declines the others for that load.';

  @override
  String get legalT4 => 'Cancellations';

  @override
  String get legalT4Body =>
      'You can cancel a request before pickup. Repeated late cancellations may affect your access.';

  @override
  String get legalT5 => 'Payments';

  @override
  String get legalT5Body =>
      'Fares are agreed between you and the carrier in Nepali rupees. Payment terms are shown before you confirm a booking.';

  @override
  String get legalP1 => 'What we collect';

  @override
  String get legalP1Body =>
      'Your name, phone number, email, company, and the details of loads you post, bids you receive and bookings you make.';

  @override
  String get legalP2 => 'How we use it';

  @override
  String get legalP2Body =>
      'To run your account, show your loads to carriers, process bookings, send service messages and improve LODBOD.';

  @override
  String get legalP3 => 'What carriers see';

  @override
  String get legalP3Body =>
      'Carriers see your company name, the route, cargo and schedule. Your phone number is shared only with the carrier you book.';

  @override
  String get legalP4 => 'Your choices';

  @override
  String get legalP4Body =>
      'You can update your profile at any time and control in-app alerts from Account.';

  @override
  String get legalP5 => 'Security';

  @override
  String get legalP5Body =>
      'Your data is stored with industry-standard encryption in transit and at rest.';

  @override
  String get trackEstimatedUnavailable =>
      'Estimated from schedule · live updates unavailable';

  @override
  String get trackSimulatedSample => 'Simulated tracking · sample route';

  @override
  String get trackJustNow => 'just now';

  @override
  String trackSecondsAgo(int s) {
    return '${s}s ago';
  }

  @override
  String trackLiveLine(String age) {
    return 'Live · simulated driver · $age';
  }

  @override
  String get trackStopped => ' · Stopped';

  @override
  String trackSpeed(int kmh) {
    return ' · $kmh km/h';
  }

  @override
  String trackAtDestination(String place) {
    return 'At $place · waiting for the carrier to confirm delivery';
  }

  @override
  String trackExpectedLate(String when, int km) {
    return 'Expected $when · $km km remaining';
  }

  @override
  String trackRemaining(String prefix, int km, String speed) {
    return '$prefix$km km remaining$speed';
  }

  @override
  String get trackAwaitingPickup => 'Awaiting pickup';

  @override
  String trackPickupTrip(String when, int km) {
    return 'Pickup $when · $km km trip';
  }

  @override
  String trackProgress(String place, int pct) {
    return '$place · $pct%';
  }

  @override
  String get trackRoute => 'Route';

  @override
  String trackPickupLine(String when) {
    return 'Pickup · $when';
  }

  @override
  String trackEstimated(String when) {
    return 'Estimated $when';
  }

  @override
  String get trackPassed => 'Passed';

  @override
  String get trackUpcoming => 'Upcoming';

  @override
  String trackFastForward(int factor) {
    return 'Simulate: fast-forward ×$factor';
  }

  @override
  String get trackEnRoute => 'En route';
}
