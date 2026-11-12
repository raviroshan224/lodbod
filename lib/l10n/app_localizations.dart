import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LODBOD Shipper'**
  String get appTitle;

  /// No description provided for @appShipper.
  ///
  /// In en, this message translates to:
  /// **'SHIPPER'**
  String get appShipper;

  /// No description provided for @appCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'LODBOD couldn\'t start'**
  String get appCouldNotStart;

  /// No description provided for @appCheckConnectionRestart.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and restart the app.'**
  String get appCheckConnectionRestart;

  /// No description provided for @appShipperOnly.
  ///
  /// In en, this message translates to:
  /// **'This app is for shipper accounts. Carriers use the LODBOD Carrier app.'**
  String get appShipperOnly;

  /// No description provided for @appVersionLine.
  ///
  /// In en, this message translates to:
  /// **'LODBOD Shipper · version {version}'**
  String appVersionLine(String version);

  /// No description provided for @errRequestLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the mobile request limit of 3. Please use the LODBOD web platform to create additional requests.'**
  String get errRequestLimit;

  /// No description provided for @errBidAlreadyAccepted.
  ///
  /// In en, this message translates to:
  /// **'A bid has already been accepted for this shipment.'**
  String get errBidAlreadyAccepted;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone/email or password. Please try again.'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Try logging in instead.'**
  String get errEmailTaken;

  /// No description provided for @errPhoneTaken.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already linked to another account.'**
  String get errPhoneTaken;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password: at least 8 characters with a number.'**
  String get errWeakPassword;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get errTooManyAttempts;

  /// No description provided for @errAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact LODBOD support.'**
  String get errAccountDisabled;

  /// No description provided for @errSignInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn\'t available right now. Please try again later.'**
  String get errSignInUnavailable;

  /// No description provided for @errOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach LODBOD. Check your connection and try again. Retrying is safe and won\'t create duplicates.'**
  String get errOffline;

  /// No description provided for @errNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this. Try signing out and in again.'**
  String get errNoAccess;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnknown;

  /// No description provided for @errRecordGone.
  ///
  /// In en, this message translates to:
  /// **'That record no longer exists.'**
  String get errRecordGone;

  /// No description provided for @errShipmentGone.
  ///
  /// In en, this message translates to:
  /// **'This shipment no longer exists.'**
  String get errShipmentGone;

  /// No description provided for @errBidGone.
  ///
  /// In en, this message translates to:
  /// **'This bid is no longer available.'**
  String get errBidGone;

  /// No description provided for @errShipmentNotAcceptingBids.
  ///
  /// In en, this message translates to:
  /// **'This shipment is no longer accepting bids ({status}).'**
  String errShipmentNotAcceptingBids(String status);

  /// No description provided for @errPickupPassedRepost.
  ///
  /// In en, this message translates to:
  /// **'The pickup time for this request has passed. Post it again with a new date.'**
  String get errPickupPassedRepost;

  /// No description provided for @errOnlyAwaitingBidsReceive.
  ///
  /// In en, this message translates to:
  /// **'Only shipments awaiting bids can receive bids.'**
  String get errOnlyAwaitingBidsReceive;

  /// No description provided for @errAlreadyHasBids.
  ///
  /// In en, this message translates to:
  /// **'This shipment already has bids.'**
  String get errAlreadyHasBids;

  /// No description provided for @errAccountNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Your account is not set up yet. Sign out and sign in again.'**
  String get errAccountNotSetUp;

  /// No description provided for @errCannotTransition.
  ///
  /// In en, this message translates to:
  /// **'This shipment can\'t be {to} because it is {status}.'**
  String errCannotTransition(String to, String status);

  /// No description provided for @errNoCarrierUpdate.
  ///
  /// In en, this message translates to:
  /// **'No carrier update applies to \"{status}\".'**
  String errNoCarrierUpdate(String status);

  /// No description provided for @errUpdatedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This shipment was updated elsewhere. Review its latest status.'**
  String get errUpdatedElsewhere;

  /// No description provided for @errCouldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the phone app. The number is +977 {phone}.'**
  String errCouldNotOpenDialer(String phone);

  /// No description provided for @errCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this'**
  String get errCouldNotLoad;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'unknown status'**
  String get unknownStatus;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'in an unknown state'**
  String get unknownState;

  /// No description provided for @timelinePosted.
  ///
  /// In en, this message translates to:
  /// **'Request posted from the mobile app'**
  String get timelinePosted;

  /// No description provided for @timelineCancelledByShipper.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by shipper'**
  String get timelineCancelledByShipper;

  /// No description provided for @timelineExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired: the pickup time passed without a booking'**
  String get timelineExpired;

  /// No description provided for @timelineBidAccepted.
  ///
  /// In en, this message translates to:
  /// **'Bid from {carrier} accepted'**
  String timelineBidAccepted(String carrier);

  /// No description provided for @timelineScheduledSim.
  ///
  /// In en, this message translates to:
  /// **'Carrier scheduled the pickup (simulated)'**
  String get timelineScheduledSim;

  /// No description provided for @timelinePickedUpSim.
  ///
  /// In en, this message translates to:
  /// **'Cargo picked up (simulated)'**
  String get timelinePickedUpSim;

  /// No description provided for @timelineDeliveredSim.
  ///
  /// In en, this message translates to:
  /// **'Delivered at destination (simulated)'**
  String get timelineDeliveredSim;

  /// No description provided for @vRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String vRequired(String label);

  /// No description provided for @vEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get vEmailRequired;

  /// No description provided for @vEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email, e.g. name@company.com'**
  String get vEmailInvalid;

  /// No description provided for @vPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get vPhoneRequired;

  /// No description provided for @vPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number starting with 97 or 98'**
  String get vPhoneInvalid;

  /// No description provided for @vPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get vPasswordRequired;

  /// No description provided for @vPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get vPasswordMin;

  /// No description provided for @vNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get vNameRequired;

  /// No description provided for @vNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get vNameInvalid;

  /// No description provided for @vPasswordUseEight.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get vPasswordUseEight;

  /// No description provided for @vPasswordLetterNumber.
  ///
  /// In en, this message translates to:
  /// **'Include at least one letter and one number'**
  String get vPasswordLetterNumber;

  /// No description provided for @vIdentifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get vIdentifierRequired;

  /// No description provided for @vPickupRequired.
  ///
  /// In en, this message translates to:
  /// **'Pickup location is required'**
  String get vPickupRequired;

  /// No description provided for @vPickupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid pickup location'**
  String get vPickupInvalid;

  /// No description provided for @vDestinationRequired.
  ///
  /// In en, this message translates to:
  /// **'Destination is required'**
  String get vDestinationRequired;

  /// No description provided for @vDestinationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid destination'**
  String get vDestinationInvalid;

  /// No description provided for @vDestinationSame.
  ///
  /// In en, this message translates to:
  /// **'Destination must be different from the pickup location'**
  String get vDestinationSame;

  /// No description provided for @vPickupDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a pickup date'**
  String get vPickupDateRequired;

  /// No description provided for @vPickupDatePast.
  ///
  /// In en, this message translates to:
  /// **'Pickup date can\'t be in the past'**
  String get vPickupDatePast;

  /// No description provided for @vPickupDateTooFar.
  ///
  /// In en, this message translates to:
  /// **'Pickup must be within the next {days} days'**
  String vPickupDateTooFar(int days);

  /// No description provided for @vPickupTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a pickup time'**
  String get vPickupTimeRequired;

  /// No description provided for @vPickupTimePast.
  ///
  /// In en, this message translates to:
  /// **'Pickup time can\'t be in the past'**
  String get vPickupTimePast;

  /// No description provided for @vCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a cargo category'**
  String get vCategoryRequired;

  /// No description provided for @vDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe the cargo, e.g. \"Steel pipes\"'**
  String get vDescriptionRequired;

  /// No description provided for @vDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the description under 80 characters'**
  String get vDescriptionTooLong;

  /// No description provided for @vWeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight is required'**
  String get vWeightRequired;

  /// No description provided for @vWeightNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter weight as a number'**
  String get vWeightNumber;

  /// No description provided for @vWeightPositive.
  ///
  /// In en, this message translates to:
  /// **'Weight must be greater than 0'**
  String get vWeightPositive;

  /// No description provided for @vWeightMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum {tonnes} t per request'**
  String vWeightMax(int tonnes);

  /// No description provided for @vVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a vehicle type'**
  String get vVehicleRequired;

  /// No description provided for @vFareWhole.
  ///
  /// In en, this message translates to:
  /// **'Enter the fare in whole rupees'**
  String get vFareWhole;

  /// No description provided for @vFarePositive.
  ///
  /// In en, this message translates to:
  /// **'Fare must be greater than 0'**
  String get vFarePositive;

  /// No description provided for @vFareTooHigh.
  ///
  /// In en, this message translates to:
  /// **'That fare looks too high'**
  String get vFareTooHigh;

  /// No description provided for @vContactNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the name under 60 characters'**
  String get vContactNameTooLong;

  /// No description provided for @vNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep notes under 300 characters'**
  String get vNotesTooLong;

  /// No description provided for @fmtJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get fmtJustNow;

  /// No description provided for @fmtMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String fmtMinutesAgo(int n);

  /// No description provided for @fmtHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String fmtHoursAgo(int n);

  /// No description provided for @fmtDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day ago} other{{n} days ago}}'**
  String fmtDaysAgo(int n);

  /// No description provided for @fmtDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String fmtDays(int n);

  /// No description provided for @fmtMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'**
  String get fmtMonthsShort;

  /// No description provided for @fmtWeekdaysShort.
  ///
  /// In en, this message translates to:
  /// **'Mon,Tue,Wed,Thu,Fri,Sat,Sun'**
  String get fmtWeekdaysShort;

  /// No description provided for @statusAwaitingBids.
  ///
  /// In en, this message translates to:
  /// **'Awaiting bids'**
  String get statusAwaitingBids;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusLabelA11y.
  ///
  /// In en, this message translates to:
  /// **'Status: {label}'**
  String statusLabelA11y(String label);

  /// No description provided for @bidPending.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bidPending;

  /// No description provided for @bidAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get bidAccepted;

  /// No description provided for @bidNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get bidNotSelected;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterClosed.
  ///
  /// In en, this message translates to:
  /// **'Cancelled / expired'**
  String get filterClosed;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup date'**
  String get sortPickupDate;

  /// No description provided for @sortStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sortStatus;

  /// No description provided for @cargoCement.
  ///
  /// In en, this message translates to:
  /// **'Cement'**
  String get cargoCement;

  /// No description provided for @cargoSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get cargoSteel;

  /// No description provided for @cargoConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction material'**
  String get cargoConstruction;

  /// No description provided for @cargoFoodGrains.
  ///
  /// In en, this message translates to:
  /// **'Food grains'**
  String get cargoFoodGrains;

  /// No description provided for @cargoFmcg.
  ///
  /// In en, this message translates to:
  /// **'FMCG'**
  String get cargoFmcg;

  /// No description provided for @cargoFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get cargoFurniture;

  /// No description provided for @cargoElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get cargoElectronics;

  /// No description provided for @cargoOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cargoOther;

  /// No description provided for @vehicleOpen.
  ///
  /// In en, this message translates to:
  /// **'Open truck'**
  String get vehicleOpen;

  /// No description provided for @vehicleClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed truck'**
  String get vehicleClosed;

  /// No description provided for @vehicleTrailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get vehicleTrailer;

  /// No description provided for @vehicleContainer.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get vehicleContainer;

  /// No description provided for @vehicleTanker.
  ///
  /// In en, this message translates to:
  /// **'Tanker'**
  String get vehicleTanker;

  /// No description provided for @vehicleTipper.
  ///
  /// In en, this message translates to:
  /// **'Tipper'**
  String get vehicleTipper;

  /// No description provided for @vehicleMini.
  ///
  /// In en, this message translates to:
  /// **'Mini truck'**
  String get vehicleMini;

  /// No description provided for @unitTonnes.
  ///
  /// In en, this message translates to:
  /// **'Tonnes'**
  String get unitTonnes;

  /// No description provided for @unitKilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get unitKilograms;

  /// No description provided for @unitTonneSymbol.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get unitTonneSymbol;

  /// No description provided for @unitKgSymbol.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKgSymbol;

  /// No description provided for @stepRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get stepRoute;

  /// No description provided for @stepCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get stepCargo;

  /// No description provided for @stepVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get stepVehicle;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @stepRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Route & schedule'**
  String get stepRouteTitle;

  /// No description provided for @stepCargoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cargo details'**
  String get stepCargoTitle;

  /// No description provided for @stepVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle & contact'**
  String get stepVehicleTitle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String stepOf(int n, int total);

  /// No description provided for @stepOfA11y.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}: {title}'**
  String stepOfA11y(int n, int total, String title);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// No description provided for @period30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get period30;

  /// No description provided for @period90.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get period90;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navShipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get navShipments;

  /// No description provided for @navPostLoad.
  ///
  /// In en, this message translates to:
  /// **'Post Load'**
  String get navPostLoad;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @navPostNewLoad.
  ///
  /// In en, this message translates to:
  /// **'Post a new load'**
  String get navPostNewLoad;

  /// No description provided for @navNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{label}, {n} need attention'**
  String navNeedAttention(String label, int n);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'{label}, {n} new'**
  String badgeNew(String label, int n);

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// No description provided for @actionGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get actionGoBack;

  /// No description provided for @actionGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionGotIt;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get actionLogIn;

  /// No description provided for @actionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get actionCreateAccount;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// No description provided for @actionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get actionSaveDraft;

  /// No description provided for @actionPostLoad.
  ///
  /// In en, this message translates to:
  /// **'Post load'**
  String get actionPostLoad;

  /// No description provided for @actionPostALoad.
  ///
  /// In en, this message translates to:
  /// **'Post a load'**
  String get actionPostALoad;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @actionKeepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get actionKeepIt;

  /// No description provided for @actionCancelShipment.
  ///
  /// In en, this message translates to:
  /// **'Cancel shipment'**
  String get actionCancelShipment;

  /// No description provided for @actionCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get actionCancelRequest;

  /// No description provided for @actionViewBids.
  ///
  /// In en, this message translates to:
  /// **'View bids'**
  String get actionViewBids;

  /// No description provided for @actionTrackShipment.
  ///
  /// In en, this message translates to:
  /// **'Track shipment'**
  String get actionTrackShipment;

  /// No description provided for @actionPostSimilar.
  ///
  /// In en, this message translates to:
  /// **'Post a similar load'**
  String get actionPostSimilar;

  /// No description provided for @actionCopyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get actionCopyReference;

  /// No description provided for @actionMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get actionMoreActions;

  /// No description provided for @actionCompareBids.
  ///
  /// In en, this message translates to:
  /// **'Compare bids'**
  String get actionCompareBids;

  /// No description provided for @actionHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get actionHowItWorks;

  /// No description provided for @actionManageRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage requests'**
  String get actionManageRequests;

  /// No description provided for @actionViewMyRequests.
  ///
  /// In en, this message translates to:
  /// **'View my requests'**
  String get actionViewMyRequests;

  /// No description provided for @actionBackToLogIn.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get actionBackToLogIn;

  /// No description provided for @actionResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get actionResendEmail;

  /// No description provided for @actionSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get actionSkipForNow;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @actionClearSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get actionClearSearchFilters;

  /// No description provided for @actionStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get actionStartOver;

  /// No description provided for @actionClearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get actionClearForm;

  /// No description provided for @actionKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// No description provided for @actionReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Review request'**
  String get actionReviewRequest;

  /// No description provided for @actionContinueTo.
  ///
  /// In en, this message translates to:
  /// **'Continue to {step}'**
  String actionContinueTo(String step);

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get fieldEmailOrPhone;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldCompany.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get fieldCompany;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aarav Shrestha'**
  String get hintName;

  /// No description provided for @hintCompany.
  ///
  /// In en, this message translates to:
  /// **'e.g. Himal Traders Pvt. Ltd.'**
  String get hintCompany;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get hintEmail;

  /// No description provided for @hintEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'you@company.com or 98XXXXXXXX'**
  String get hintEmailOrPhone;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with a letter and a number'**
  String get passwordHint;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get passwordWeak;

  /// No description provided for @passwordGood.
  ///
  /// In en, this message translates to:
  /// **'Good password'**
  String get passwordGood;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get passwordStrong;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your loads and shipments.'**
  String get loginSubtitle;

  /// No description provided for @loginForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgot;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @legalByContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the '**
  String get legalByContinuing;

  /// No description provided for @legalIAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get legalIAgree;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalAnd;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTerms;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacy;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post loads and compare carrier bids in minutes.'**
  String get registerSubtitle;

  /// No description provided for @registerVerifyHelper.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification link here.'**
  String get registerVerifyHelper;

  /// No description provided for @registerAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to create an account'**
  String get registerAcceptTerms;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email or phone number on your account and we will email you a link to set a new password.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotSend;

  /// No description provided for @forgotRemembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get forgotRemembered;

  /// No description provided for @forgotSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotSentTitle;

  /// No description provided for @forgotSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {identifier}, a link to reset your password is on its way. It may take a minute; if it doesn\'t arrive, check your spam folder.'**
  String forgotSentBody(String identifier);

  /// No description provided for @forgotUseDifferent.
  ///
  /// In en, this message translates to:
  /// **'Use a different email or phone'**
  String get forgotUseDifferent;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyTitle;

  /// No description provided for @verifySentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to '**
  String get verifySentTo;

  /// No description provided for @verifyOpenIt.
  ///
  /// In en, this message translates to:
  /// **'. Open it to activate your account.'**
  String get verifyOpenIt;

  /// No description provided for @verifyDone.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get verifyDone;

  /// No description provided for @verifyDidntGet.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get verifyDidntGet;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in 0:{seconds}'**
  String verifyResendIn(String seconds);

  /// No description provided for @verifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Welcome to LODBOD!'**
  String get verifySuccess;

  /// No description provided for @verifyNotYet.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm it yet. Open the link in the email, then try again.'**
  String get verifyNotYet;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again.'**
  String get verifyResent;

  /// No description provided for @verifyLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent. Check your inbox.'**
  String get verifyLinkSent;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up'**
  String get completeTitle;

  /// No description provided for @completeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us who you are so carriers know who they are working with.'**
  String get completeSubtitle;

  /// No description provided for @splashChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your session…'**
  String get splashChecking;

  /// No description provided for @splashLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your account'**
  String get splashLoadFailed;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get homeGoodEvening;

  /// No description provided for @homeShipNew.
  ///
  /// In en, this message translates to:
  /// **'Ship something new'**
  String get homeShipNew;

  /// No description provided for @homeRequestsUsed.
  ///
  /// In en, this message translates to:
  /// **'Mobile requests used: '**
  String get homeRequestsUsed;

  /// No description provided for @homeUsedOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String homeUsedOf(int used, int limit);

  /// No description provided for @homeUsedOfInUse.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} in use'**
  String homeUsedOfInUse(int used, int limit);

  /// No description provided for @homeRequestsInUseA11y.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} mobile requests in use'**
  String homeRequestsInUseA11y(int used, int limit);

  /// No description provided for @homeAllInUse.
  ///
  /// In en, this message translates to:
  /// **'All {limit} are in use. Finish or cancel one to post a new load. '**
  String homeAllInUse(int limit);

  /// No description provided for @homeNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs your action'**
  String get homeNeedsAction;

  /// No description provided for @homeBidsOn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 bid on {reference}} other{{n} bids on {reference}}}'**
  String homeBidsOn(int n, String reference);

  /// No description provided for @homeRoutePickup.
  ///
  /// In en, this message translates to:
  /// **'{route} · Pickup {date}'**
  String homeRoutePickup(String route, String date);

  /// No description provided for @homeOnTheRoad.
  ///
  /// In en, this message translates to:
  /// **'On the road'**
  String get homeOnTheRoad;

  /// No description provided for @homeNextPickup.
  ///
  /// In en, this message translates to:
  /// **'Next pickup'**
  String get homeNextPickup;

  /// No description provided for @homeOtherShipments.
  ///
  /// In en, this message translates to:
  /// **'Other shipments'**
  String get homeOtherShipments;

  /// No description provided for @homeSeeAllN.
  ///
  /// In en, this message translates to:
  /// **'See all {n} shipments'**
  String homeSeeAllN(int n);

  /// No description provided for @homeStatA11y.
  ///
  /// In en, this message translates to:
  /// **'{count} {label}. Show these shipments'**
  String homeStatA11y(int count, String label);

  /// No description provided for @homeLeft.
  ///
  /// In en, this message translates to:
  /// **'Left {place}'**
  String homeLeft(String place);

  /// No description provided for @homePassed.
  ///
  /// In en, this message translates to:
  /// **'Passed {place}'**
  String homePassed(String place);

  /// No description provided for @homeKmLeft.
  ///
  /// In en, this message translates to:
  /// **'{where} · {km} km left'**
  String homeKmLeft(String where, int km);

  /// No description provided for @runningLate.
  ///
  /// In en, this message translates to:
  /// **'Running late'**
  String get runningLate;

  /// No description provided for @etaTime.
  ///
  /// In en, this message translates to:
  /// **'ETA {time}'**
  String etaTime(String time);

  /// No description provided for @simulatedTracking.
  ///
  /// In en, this message translates to:
  /// **'Simulated tracking'**
  String get simulatedTracking;

  /// No description provided for @homeSamplesAdded.
  ///
  /// In en, this message translates to:
  /// **'Sample shipments added. Have a look around!'**
  String get homeSamplesAdded;

  /// No description provided for @homeSamplesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add sample shipments. Try again.'**
  String get homeSamplesFailed;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LODBOD'**
  String get homeWelcome;

  /// No description provided for @homeWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Move goods across Nepal with trusted carriers. Here is how it works:'**
  String get homeWelcomeBody;

  /// No description provided for @homeStep1.
  ///
  /// In en, this message translates to:
  /// **'Post a load'**
  String get homeStep1;

  /// No description provided for @homeStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Route, cargo and truck in under a minute.'**
  String get homeStep1Body;

  /// No description provided for @homeStep2.
  ///
  /// In en, this message translates to:
  /// **'Compare bids'**
  String get homeStep2;

  /// No description provided for @homeStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Verified carriers send offers you can compare.'**
  String get homeStep2Body;

  /// No description provided for @homeStep3.
  ///
  /// In en, this message translates to:
  /// **'Track delivery'**
  String get homeStep3;

  /// No description provided for @homeStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Follow every step until it is delivered.'**
  String get homeStep3Body;

  /// No description provided for @homePostFirst.
  ///
  /// In en, this message translates to:
  /// **'Post your first load'**
  String get homePostFirst;

  /// No description provided for @homeExploreSamples.
  ///
  /// In en, this message translates to:
  /// **'Explore with sample shipments'**
  String get homeExploreSamples;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your shipments'**
  String get homeLoading;

  /// No description provided for @shipmentsSort.
  ///
  /// In en, this message translates to:
  /// **'Sort shipments'**
  String get shipmentsSort;

  /// No description provided for @shipmentsSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort: {sort}'**
  String shipmentsSortBy(String sort);

  /// No description provided for @shipmentsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search reference, route or cargo'**
  String get shipmentsSearchHint;

  /// No description provided for @shipmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 shipment} other{{n} shipments}} · {sort}'**
  String shipmentsCount(int n, String sort);

  /// No description provided for @shipmentsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching shipments'**
  String get shipmentsNoMatch;

  /// No description provided for @shipmentsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different reference, city or status.'**
  String get shipmentsNoMatchBody;

  /// No description provided for @shipmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get shipmentsEmpty;

  /// No description provided for @shipmentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Post a load and carriers will start bidding on it.'**
  String get shipmentsEmptyBody;

  /// No description provided for @cardA11y.
  ///
  /// In en, this message translates to:
  /// **'{reference}, {status}, {from} to {to}'**
  String cardA11y(String reference, String status, String from, String to);

  /// No description provided for @cardPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted {when}'**
  String cardPosted(String when);

  /// No description provided for @cardWaitingForBids.
  ///
  /// In en, this message translates to:
  /// **'Waiting for bids'**
  String get cardWaitingForBids;

  /// No description provided for @cardBids.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 bid} other{{n} bids}}'**
  String cardBids(int n);

  /// No description provided for @cardFarePending.
  ///
  /// In en, this message translates to:
  /// **'Fare pending'**
  String get cardFarePending;

  /// No description provided for @cardBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}'**
  String cardBudget(String amount);

  /// No description provided for @cardStatusWhen.
  ///
  /// In en, this message translates to:
  /// **'{status} {when}'**
  String cardStatusWhen(String status, String when);

  /// No description provided for @cardDeliveredOn.
  ///
  /// In en, this message translates to:
  /// **'Delivered {date}'**
  String cardDeliveredOn(String date);

  /// No description provided for @cardCarrierAssigned.
  ///
  /// In en, this message translates to:
  /// **'Carrier assigned'**
  String get cardCarrierAssigned;

  /// No description provided for @cardPickupAt.
  ///
  /// In en, this message translates to:
  /// **'Pickup {time}'**
  String cardPickupAt(String time);

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @cardPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up {when}'**
  String cardPickedUp(String when);

  /// No description provided for @routeAtoB.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String routeAtoB(String from, String to);

  /// No description provided for @timelinePostedStep.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get timelinePostedStep;

  /// No description provided for @timelineBookedStep.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get timelineBookedStep;

  /// No description provided for @timelineA11y.
  ///
  /// In en, this message translates to:
  /// **'Shipment {status}'**
  String timelineA11y(String status);

  /// No description provided for @timelineStepA11y.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of 5: {label}'**
  String timelineStepA11y(int n, String label);

  /// No description provided for @detailsPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted {date}'**
  String detailsPosted(String date);

  /// No description provided for @detailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Shipment not found'**
  String get detailsNotFound;

  /// No description provided for @detailsNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed. Go back to your shipments.'**
  String get detailsNotFoundBody;

  /// No description provided for @detailsRemoved.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed.'**
  String get detailsRemoved;

  /// No description provided for @detailsPickupLine.
  ///
  /// In en, this message translates to:
  /// **'Pickup · {when}'**
  String detailsPickupLine(String when);

  /// No description provided for @detailsDeliveredLine.
  ///
  /// In en, this message translates to:
  /// **'Delivered · {when}'**
  String detailsDeliveredLine(String when);

  /// No description provided for @detailsEtaLine.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival · {when}'**
  String detailsEtaLine(String when);

  /// No description provided for @detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Shipment details'**
  String get detailsSection;

  /// No description provided for @detailsCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get detailsCargo;

  /// No description provided for @detailsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailsWeight;

  /// No description provided for @detailsVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get detailsVehicle;

  /// No description provided for @detailsYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Your budget'**
  String get detailsYourBudget;

  /// No description provided for @openToBids.
  ///
  /// In en, this message translates to:
  /// **'Open to bids'**
  String get openToBids;

  /// No description provided for @detailsContactSection.
  ///
  /// In en, this message translates to:
  /// **'Pickup contact & notes'**
  String get detailsContactSection;

  /// No description provided for @detailsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get detailsContact;

  /// No description provided for @detailsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get detailsPhone;

  /// No description provided for @detailsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailsNotes;

  /// No description provided for @detailsCall.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String detailsCall(String name);

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'contact'**
  String get contact;

  /// No description provided for @detailsActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get detailsActivity;

  /// No description provided for @detailsDropOff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get detailsDropOff;

  /// No description provided for @detailsCarriersHaveBid.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 carrier has bid} other{{n} carriers have bid}}'**
  String detailsCarriersHaveBid(int n);

  /// No description provided for @detailsFindingCarriers.
  ///
  /// In en, this message translates to:
  /// **'Finding carriers…'**
  String get detailsFindingCarriers;

  /// No description provided for @detailsCompareBody.
  ///
  /// In en, this message translates to:
  /// **'Compare price, rating and delivery time, then book one.'**
  String get detailsCompareBody;

  /// No description provided for @detailsVisibleBody.
  ///
  /// In en, this message translates to:
  /// **'Your load is visible to carriers. Bids usually arrive within minutes.'**
  String get detailsVisibleBody;

  /// No description provided for @detailsCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'This request was cancelled'**
  String get detailsCancelledTitle;

  /// No description provided for @detailsExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'This request expired'**
  String get detailsExpiredTitle;

  /// No description provided for @detailsClosedBody.
  ///
  /// In en, this message translates to:
  /// **'It no longer counts toward your mobile request limit. You can post it again in a tap.'**
  String get detailsClosedBody;

  /// No description provided for @detailsAgreedFare.
  ///
  /// In en, this message translates to:
  /// **'Agreed fare'**
  String get detailsAgreedFare;

  /// No description provided for @detailsEstimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get detailsEstimatedArrival;

  /// No description provided for @detailsKmToGo.
  ///
  /// In en, this message translates to:
  /// **'{where} · {km} km to go · simulated'**
  String detailsKmToGo(String where, int km);

  /// No description provided for @detailsReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace your unfinished load?'**
  String get detailsReplaceTitle;

  /// No description provided for @detailsReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'You have a load you were still filling in. Starting from {reference} will replace it.'**
  String detailsReplaceBody(String reference);

  /// No description provided for @detailsReplaceIt.
  ///
  /// In en, this message translates to:
  /// **'Replace it'**
  String get detailsReplaceIt;

  /// No description provided for @detailsCompareN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Compare 1 bid} other{Compare {n} bids}}'**
  String detailsCompareN(int n);

  /// No description provided for @detailsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel {reference}?'**
  String detailsCancelTitle(String reference);

  /// No description provided for @detailsCancelOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Carriers will no longer be able to bid, and any open bids will be declined.'**
  String get detailsCancelOpenBody;

  /// No description provided for @detailsCancelBookedBody.
  ///
  /// In en, this message translates to:
  /// **'Your booking with {carrier} will be cancelled.'**
  String detailsCancelBookedBody(String carrier);

  /// No description provided for @theCarrier.
  ///
  /// In en, this message translates to:
  /// **'the carrier'**
  String get theCarrier;

  /// No description provided for @detailsCancelled.
  ///
  /// In en, this message translates to:
  /// **'{reference} cancelled.'**
  String detailsCancelled(String reference);

  /// No description provided for @detailsCopied.
  ///
  /// In en, this message translates to:
  /// **'{reference} copied'**
  String detailsCopied(String reference);

  /// No description provided for @simCarrierUpdate.
  ///
  /// In en, this message translates to:
  /// **'Simulate carrier update'**
  String get simCarrierUpdate;

  /// No description provided for @simCarrierUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'Mark {reference} as \"{status}\". In the live service this update comes from the carrier.'**
  String simCarrierUpdateBody(String reference, String status);

  /// No description provided for @simMark.
  ///
  /// In en, this message translates to:
  /// **'Mark {status}'**
  String simMark(String status);

  /// No description provided for @simNowStatus.
  ///
  /// In en, this message translates to:
  /// **'{reference} is now {status}.'**
  String simNowStatus(String reference, String status);

  /// No description provided for @simMenuMark.
  ///
  /// In en, this message translates to:
  /// **'Simulate: mark {status}'**
  String simMenuMark(String status);

  /// No description provided for @simDemoCarrierUpdate.
  ///
  /// In en, this message translates to:
  /// **'Demo carrier update'**
  String get simDemoCarrierUpdate;

  /// No description provided for @simBidsNow.
  ///
  /// In en, this message translates to:
  /// **'Simulate: bids arrive now'**
  String get simBidsNow;

  /// No description provided for @simDemoBids.
  ///
  /// In en, this message translates to:
  /// **'Demo carrier bids'**
  String get simDemoBids;

  /// No description provided for @simBidsNowDemo.
  ///
  /// In en, this message translates to:
  /// **'Simulate bids now (demo)'**
  String get simBidsNowDemo;

  /// No description provided for @bidsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bids'**
  String get bidsTitle;

  /// No description provided for @bidsRefRoute.
  ///
  /// In en, this message translates to:
  /// **'{reference} · {route}'**
  String bidsRefRoute(String reference, String route);

  /// No description provided for @bidsCargoWeight.
  ///
  /// In en, this message translates to:
  /// **'{cargo} · {weight}'**
  String bidsCargoWeight(String cargo, String weight);

  /// No description provided for @bidsPickupVehicle.
  ///
  /// In en, this message translates to:
  /// **'Pickup {when} · {vehicle}'**
  String bidsPickupVehicle(String when, String vehicle);

  /// No description provided for @bidsBudgetLine.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}'**
  String bidsBudgetLine(String amount);

  /// No description provided for @bidsBookedWith.
  ///
  /// In en, this message translates to:
  /// **'Booked with {carrier}'**
  String bidsBookedWith(String carrier);

  /// No description provided for @bidsBookedBody.
  ///
  /// In en, this message translates to:
  /// **'{fare} · {reference} is {status}.'**
  String bidsBookedBody(String fare, String reference, String status);

  /// No description provided for @bidsClosedBody.
  ///
  /// In en, this message translates to:
  /// **'This shipment is {status} and no longer accepting bids.'**
  String bidsClosedBody(String status);

  /// No description provided for @bidsOffers.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 offer} other{{n} offers}}'**
  String bidsOffers(int n);

  /// No description provided for @bidsSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get bidsSortBy;

  /// No description provided for @bidsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get bidsSortNewest;

  /// No description provided for @bidsSortPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get bidsSortPrice;

  /// No description provided for @bidsSortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get bidsSortRating;

  /// No description provided for @bidsSortFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get bidsSortFastest;

  /// No description provided for @bidsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for carriers'**
  String get bidsWaiting;

  /// No description provided for @bidsNone.
  ///
  /// In en, this message translates to:
  /// **'No bids'**
  String get bidsNone;

  /// No description provided for @bidsWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Your load is visible to carriers. Offers usually arrive within minutes, and we will notify you.'**
  String get bidsWaitingBody;

  /// No description provided for @bidsNoneBody.
  ///
  /// In en, this message translates to:
  /// **'This shipment did not receive any bids.'**
  String get bidsNoneBody;

  /// No description provided for @bidUnder.
  ///
  /// In en, this message translates to:
  /// **'{amount} under'**
  String bidUnder(String amount);

  /// No description provided for @bidOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String bidOver(String amount);

  /// No description provided for @bidA11y.
  ///
  /// In en, this message translates to:
  /// **'{carrier}, {fare}, {days}, rated {rating}'**
  String bidA11y(String carrier, String fare, String days, String rating);

  /// No description provided for @bidDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get bidDelivery;

  /// No description provided for @bidVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get bidVehicle;

  /// No description provided for @bidBy.
  ///
  /// In en, this message translates to:
  /// **'by {date}'**
  String bidBy(String date);

  /// No description provided for @bidReceived.
  ///
  /// In en, this message translates to:
  /// **'Received {when}'**
  String bidReceived(String when);

  /// No description provided for @bidRatedA11y.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5 from {trips} trips'**
  String bidRatedA11y(String rating, int trips);

  /// No description provided for @bidTrips.
  ///
  /// In en, this message translates to:
  /// **'  ·  {trips} trips'**
  String bidTrips(int trips);

  /// No description provided for @offerTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get offerTitle;

  /// No description provided for @offerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bid not found'**
  String get offerNotFound;

  /// No description provided for @offerNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This bid may have been withdrawn.'**
  String get offerNotFoundBody;

  /// No description provided for @offerBooked.
  ///
  /// In en, this message translates to:
  /// **'You booked this carrier'**
  String get offerBooked;

  /// No description provided for @offerBookedBody.
  ///
  /// In en, this message translates to:
  /// **'{reference} is {status} with {carrier}'**
  String offerBookedBody(String reference, String status, String carrier);

  /// No description provided for @offerNotSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Not selected: you booked another carrier for {reference}.'**
  String offerNotSelectedBody(String reference);

  /// No description provided for @offerClosedBody.
  ///
  /// In en, this message translates to:
  /// **'{reference} is {status}, so this offer can no longer be accepted.'**
  String offerClosedBody(String reference, String status);

  /// No description provided for @offerFare.
  ///
  /// In en, this message translates to:
  /// **'Offered fare'**
  String get offerFare;

  /// No description provided for @offerSection.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerSection;

  /// No description provided for @offerAfterPickup.
  ///
  /// In en, this message translates to:
  /// **'{days} after pickup'**
  String offerAfterPickup(String days);

  /// No description provided for @offerArrivesBy.
  ///
  /// In en, this message translates to:
  /// **'Arrives by'**
  String get offerArrivesBy;

  /// No description provided for @offerEstimate.
  ///
  /// In en, this message translates to:
  /// **'{date} (estimate)'**
  String offerEstimate(String date);

  /// No description provided for @offerReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get offerReceived;

  /// No description provided for @offerNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get offerNote;

  /// No description provided for @offerYourLoad.
  ///
  /// In en, this message translates to:
  /// **'Your load'**
  String get offerYourLoad;

  /// No description provided for @offerPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get offerPickup;

  /// No description provided for @offerRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get offerRequested;

  /// No description provided for @offerMatchesBudget.
  ///
  /// In en, this message translates to:
  /// **'Matches your budget'**
  String get offerMatchesBudget;

  /// No description provided for @offerDiffBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} {direction} your budget'**
  String offerDiffBudget(String amount, String direction);

  /// No description provided for @over.
  ///
  /// In en, this message translates to:
  /// **'over'**
  String get over;

  /// No description provided for @under.
  ///
  /// In en, this message translates to:
  /// **'under'**
  String get under;

  /// No description provided for @offerConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'You confirm before anything is booked'**
  String get offerConfirmNote;

  /// No description provided for @acceptFor.
  ///
  /// In en, this message translates to:
  /// **'Accept for {amount}'**
  String acceptFor(String amount);

  /// No description provided for @acceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Book {carrier}?'**
  String acceptTitle(String carrier);

  /// No description provided for @acceptBody.
  ///
  /// In en, this message translates to:
  /// **'This confirms {reference} with this carrier. {others}This can\'t be undone from the app.'**
  String acceptBody(String reference, String others);

  /// No description provided for @acceptOthersDeclined.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{The other offer will be declined. } other{The other {n} offers will be declined. }}'**
  String acceptOthersDeclined(int n);

  /// No description provided for @acceptRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get acceptRoute;

  /// No description provided for @acceptFare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get acceptFare;

  /// No description provided for @acceptAbout.
  ///
  /// In en, this message translates to:
  /// **'About {days}'**
  String acceptAbout(String days);

  /// No description provided for @acceptBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked! {reference} is confirmed with {carrier}'**
  String acceptBooked(String reference, String carrier);

  /// No description provided for @acceptFailed.
  ///
  /// In en, this message translates to:
  /// **'{message} The offer hasn\'t been accepted yet.'**
  String acceptFailed(String message);

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a load'**
  String get postTitle;

  /// No description provided for @postPostingAs.
  ///
  /// In en, this message translates to:
  /// **'Posting as {company}'**
  String postPostingAs(String company);

  /// No description provided for @postResumed.
  ///
  /// In en, this message translates to:
  /// **'Picked up where you left off'**
  String get postResumed;

  /// No description provided for @postDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved. Finish it any time from Post Load.'**
  String get postDraftSaved;

  /// No description provided for @postDraftSavedShort.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get postDraftSavedShort;

  /// No description provided for @postStartOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get postStartOverTitle;

  /// No description provided for @postStartOverBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you entered for this load will be cleared, including the saved draft.'**
  String get postStartOverBody;

  /// No description provided for @postAllInUse.
  ///
  /// In en, this message translates to:
  /// **'All 3 mobile requests are in use'**
  String get postAllInUse;

  /// No description provided for @postAllInUseBody.
  ///
  /// In en, this message translates to:
  /// **'Prepare it now and post it once one of your requests is delivered or cancelled.'**
  String get postAllInUseBody;

  /// No description provided for @postAllInUseReviewBody.
  ///
  /// In en, this message translates to:
  /// **'You can post this load once one of your requests is delivered or cancelled.'**
  String get postAllInUseReviewBody;

  /// No description provided for @postDoneA11y.
  ///
  /// In en, this message translates to:
  /// **'{title}: {summary}. Edit'**
  String postDoneA11y(String title, String summary);

  /// No description provided for @postPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup date'**
  String get postPickupDate;

  /// No description provided for @postPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup time'**
  String get postPickupTime;

  /// No description provided for @postTimePassed.
  ///
  /// In en, this message translates to:
  /// **'That time has already passed today. Choose a later time.'**
  String get postTimePassed;

  /// No description provided for @postToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get postToday;

  /// No description provided for @postTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get postTomorrow;

  /// No description provided for @postPlus2Days.
  ///
  /// In en, this message translates to:
  /// **'+2 days'**
  String get postPlus2Days;

  /// No description provided for @postPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get postPickDate;

  /// No description provided for @postPickupCity.
  ///
  /// In en, this message translates to:
  /// **'Pickup city'**
  String get postPickupCity;

  /// No description provided for @postDestinationCity.
  ///
  /// In en, this message translates to:
  /// **'Destination city'**
  String get postDestinationCity;

  /// No description provided for @postSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap pickup and destination'**
  String get postSwap;

  /// No description provided for @postRecent.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get postRecent;

  /// No description provided for @postMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get postMorning;

  /// No description provided for @postMidday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get postMidday;

  /// No description provided for @postAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get postAfternoon;

  /// No description provided for @postEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get postEvening;

  /// No description provided for @postExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get postExact;

  /// No description provided for @postPickTime.
  ///
  /// In en, this message translates to:
  /// **'pick time'**
  String get postPickTime;

  /// No description provided for @postSlotsPassedAll.
  ///
  /// In en, this message translates to:
  /// **'Today\'s usual slots have passed. Pick an exact time or another day.'**
  String get postSlotsPassedAll;

  /// No description provided for @postSlotsPassedSome.
  ///
  /// In en, this message translates to:
  /// **'Earlier times today have passed. Pick a later slot or an exact time.'**
  String get postSlotsPassedSome;

  /// No description provided for @postMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get postMaterial;

  /// No description provided for @postWhatShipping.
  ///
  /// In en, this message translates to:
  /// **'What are you shipping?'**
  String get postWhatShipping;

  /// No description provided for @postWhatShippingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 240 cement bags, steel pipes'**
  String get postWhatShippingHint;

  /// No description provided for @postTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get postTotalWeight;

  /// No description provided for @postWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get postWeightHint;

  /// No description provided for @postVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get postVehicleType;

  /// No description provided for @postYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Your budget'**
  String get postYourBudget;

  /// No description provided for @postBudgetHelper.
  ///
  /// In en, this message translates to:
  /// **'Carriers see this as a guide and can bid above or below it.'**
  String get postBudgetHelper;

  /// No description provided for @postPickupContact.
  ///
  /// In en, this message translates to:
  /// **'Pickup contact'**
  String get postPickupContact;

  /// No description provided for @postContactHint.
  ///
  /// In en, this message translates to:
  /// **'Name at the pickup point'**
  String get postContactHint;

  /// No description provided for @postNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes for carriers'**
  String get postNotes;

  /// No description provided for @postNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Loading instructions, packaging, gate timings…'**
  String get postNotesHint;

  /// No description provided for @reviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check everything before posting'**
  String get reviewSubtitle;

  /// No description provided for @reviewNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'A few details need attention before posting.'**
  String get reviewNeedsAttention;

  /// No description provided for @reviewLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Request limit reached'**
  String get reviewLimitReached;

  /// No description provided for @reviewCouldNotPost.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your load'**
  String get reviewCouldNotPost;

  /// No description provided for @reviewDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'{message} Your details are saved.'**
  String reviewDetailsSaved(String message);

  /// No description provided for @reviewMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get reviewMaterial;

  /// No description provided for @reviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reviewDescription;

  /// No description provided for @reviewWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get reviewWeight;

  /// No description provided for @reviewVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get reviewVehicle;

  /// No description provided for @reviewBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get reviewBudget;

  /// No description provided for @reviewContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get reviewContact;

  /// No description provided for @reviewPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get reviewPhone;

  /// No description provided for @reviewNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get reviewNotes;

  /// No description provided for @reviewUsesRequest.
  ///
  /// In en, this message translates to:
  /// **'Posting uses mobile request {n} of {limit}. Carriers can start bidding straight away.'**
  String reviewUsesRequest(int n, int limit);

  /// No description provided for @postedTitle.
  ///
  /// In en, this message translates to:
  /// **'Load posted'**
  String get postedTitle;

  /// No description provided for @postedLive.
  ///
  /// In en, this message translates to:
  /// **'Your request is live.'**
  String get postedLive;

  /// No description provided for @postedLiveBody.
  ///
  /// In en, this message translates to:
  /// **'{reference} is live. We\'ll let you know as soon as the first bid arrives.'**
  String postedLiveBody(String reference);

  /// No description provided for @postedRequestCreated.
  ///
  /// In en, this message translates to:
  /// **'REQUEST CREATED'**
  String get postedRequestCreated;

  /// No description provided for @postedPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get postedPickup;

  /// No description provided for @postedCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get postedCargo;

  /// No description provided for @postedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get postedVehicle;

  /// No description provided for @postedViewRequest.
  ///
  /// In en, this message translates to:
  /// **'View request & bids'**
  String get postedViewRequest;

  /// No description provided for @postedPostAnother.
  ///
  /// In en, this message translates to:
  /// **'Post another load'**
  String get postedPostAnother;

  /// No description provided for @limitTitleReached.
  ///
  /// In en, this message translates to:
  /// **'Request limit reached'**
  String get limitTitleReached;

  /// No description provided for @limitTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile request limit'**
  String get limitTitle;

  /// No description provided for @limitBody.
  ///
  /// In en, this message translates to:
  /// **'You can have up to {max} open requests from the mobile app at a time. You are using {used} of {limit}.'**
  String limitBody(int max, int used, int limit);

  /// No description provided for @limitDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your details are saved. You can submit as soon as a request is delivered, cancelled or expires.'**
  String get limitDetailsSaved;

  /// No description provided for @limitCanPost.
  ///
  /// In en, this message translates to:
  /// **'You can post a new load as soon as a request is delivered, cancelled or expires.'**
  String get limitCanPost;

  /// No description provided for @limitCounts.
  ///
  /// In en, this message translates to:
  /// **'Counts toward the limit'**
  String get limitCounts;

  /// No description provided for @limitDoesNotCount.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t count'**
  String get limitDoesNotCount;

  /// No description provided for @notifNewBid.
  ///
  /// In en, this message translates to:
  /// **'New bid on {reference}'**
  String notifNewBid(String reference);

  /// No description provided for @notifNewBidBody.
  ///
  /// In en, this message translates to:
  /// **'{carrier} offered {fare} · {days} delivery'**
  String notifNewBidBody(String carrier, String fare, String days);

  /// No description provided for @notifLive.
  ///
  /// In en, this message translates to:
  /// **'{reference} is live'**
  String notifLive(String reference);

  /// No description provided for @notifLiveBody.
  ///
  /// In en, this message translates to:
  /// **'{route} · carriers can now bid'**
  String notifLiveBody(String route);

  /// No description provided for @notifConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{reference} confirmed'**
  String notifConfirmed(String reference);

  /// No description provided for @notifConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'A carrier has been booked'**
  String get notifConfirmedBody;

  /// No description provided for @notifScheduled.
  ///
  /// In en, this message translates to:
  /// **'Pickup scheduled for {reference}'**
  String notifScheduled(String reference);

  /// No description provided for @notifScheduledBody.
  ///
  /// In en, this message translates to:
  /// **'{carrier} · {when}'**
  String notifScheduledBody(String carrier, String when);

  /// No description provided for @notifOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'{reference} is on the way'**
  String notifOnTheWay(String reference);

  /// No description provided for @notifPickedUpIn.
  ///
  /// In en, this message translates to:
  /// **'Picked up in {place}'**
  String notifPickedUpIn(String place);

  /// No description provided for @notifDelivered.
  ///
  /// In en, this message translates to:
  /// **'{reference} delivered'**
  String notifDelivered(String reference);

  /// No description provided for @notifDeliveredIn.
  ///
  /// In en, this message translates to:
  /// **'Delivered in {place}'**
  String notifDeliveredIn(String place);

  /// No description provided for @notifCancelled.
  ///
  /// In en, this message translates to:
  /// **'{reference} cancelled'**
  String notifCancelled(String reference);

  /// No description provided for @notifExpired.
  ///
  /// In en, this message translates to:
  /// **'{reference} expired'**
  String notifExpired(String reference);

  /// No description provided for @notifExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'No carrier was booked before pickup'**
  String get notifExpiredBody;

  /// No description provided for @notifNewBidsOn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{New bid on {reference}} other{{n} new bids on {reference}}}'**
  String notifNewBidsOn(int n, String reference);

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifToday;

  /// No description provided for @notifYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifYesterday;

  /// No description provided for @notifEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifEarlier;

  /// No description provided for @notifCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notifCaughtUp;

  /// No description provided for @notifCaughtUpBody.
  ///
  /// In en, this message translates to:
  /// **'Bids, bookings and delivery updates will show up here.'**
  String get notifCaughtUpBody;

  /// No description provided for @notifView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get notifView;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your shipping is going'**
  String get analyticsSubtitle;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get analyticsNoData;

  /// No description provided for @analyticsNothingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period'**
  String get analyticsNothingPeriod;

  /// No description provided for @analyticsNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'Your stats appear once you post a load.'**
  String get analyticsNoDataBody;

  /// No description provided for @analyticsNothingPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Try a longer period to see your activity.'**
  String get analyticsNothingPeriodBody;

  /// No description provided for @analyticsBookedSpend.
  ///
  /// In en, this message translates to:
  /// **'Booked spend · {period}'**
  String analyticsBookedSpend(String period);

  /// No description provided for @analyticsBookedLoads.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 booked load} other{{n} booked loads}}'**
  String analyticsBookedLoads(int n);

  /// No description provided for @analyticsAvgPerLoad.
  ///
  /// In en, this message translates to:
  /// **' · avg {amount} per load'**
  String analyticsAvgPerLoad(String amount);

  /// No description provided for @analyticsLoadsPosted.
  ///
  /// In en, this message translates to:
  /// **'Loads posted'**
  String get analyticsLoadsPosted;

  /// No description provided for @analyticsOpenNow.
  ///
  /// In en, this message translates to:
  /// **'{n} open now'**
  String analyticsOpenNow(int n);

  /// No description provided for @analyticsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get analyticsDelivered;

  /// No description provided for @analyticsTonnesMoved.
  ///
  /// In en, this message translates to:
  /// **'{t} t moved'**
  String analyticsTonnesMoved(String t);

  /// No description provided for @analyticsBidsReceived.
  ///
  /// In en, this message translates to:
  /// **'Bids received'**
  String get analyticsBidsReceived;

  /// No description provided for @analyticsAcrossLoads.
  ///
  /// In en, this message translates to:
  /// **'across {n} loads'**
  String analyticsAcrossLoads(int n);

  /// No description provided for @analyticsAvgBids.
  ///
  /// In en, this message translates to:
  /// **'Avg. bids per load'**
  String get analyticsAvgBids;

  /// No description provided for @analyticsPerPostedLoad.
  ///
  /// In en, this message translates to:
  /// **'per posted load'**
  String get analyticsPerPostedLoad;

  /// No description provided for @analyticsByStatus.
  ///
  /// In en, this message translates to:
  /// **'Shipments by status'**
  String get analyticsByStatus;

  /// No description provided for @analyticsTopRoutes.
  ///
  /// In en, this message translates to:
  /// **'Top routes'**
  String get analyticsTopRoutes;

  /// No description provided for @analyticsLoads.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 load} other{{n} loads}}'**
  String analyticsLoads(int n);

  /// No description provided for @analyticsStatusA11y.
  ///
  /// In en, this message translates to:
  /// **'{status}: {count}'**
  String analyticsStatusA11y(String status, int count);

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountShipperLine.
  ///
  /// In en, this message translates to:
  /// **'{company} · Shipper'**
  String accountShipperLine(String company);

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile & company'**
  String get accountProfile;

  /// No description provided for @accountVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get accountVerify;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get accountVerified;

  /// No description provided for @accountSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get accountSending;

  /// No description provided for @accountMobileRequests.
  ///
  /// In en, this message translates to:
  /// **'Mobile requests'**
  String get accountMobileRequests;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get accountPreferences;

  /// No description provided for @accountLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguage;

  /// No description provided for @accountAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get accountAppearance;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @accountNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountNewBidAlerts.
  ///
  /// In en, this message translates to:
  /// **'New bid alerts'**
  String get accountNewBidAlerts;

  /// No description provided for @accountDeliveryUpdates.
  ///
  /// In en, this message translates to:
  /// **'Delivery updates'**
  String get accountDeliveryUpdates;

  /// No description provided for @accountSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & feedback'**
  String get accountSupport;

  /// No description provided for @accountHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get accountHelpCenter;

  /// No description provided for @accountSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get accountSendFeedback;

  /// No description provided for @accountLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get accountLegal;

  /// No description provided for @accountDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get accountDemo;

  /// No description provided for @accountLoadSamples.
  ///
  /// In en, this message translates to:
  /// **'Load sample shipments'**
  String get accountLoadSamples;

  /// No description provided for @accountLoadSamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Load sample shipments?'**
  String get accountLoadSamplesTitle;

  /// No description provided for @accountLoadSamplesBody.
  ///
  /// In en, this message translates to:
  /// **'Your shipments and bids will be replaced with a sample set (LOD-1001 to LOD-1004) so you can explore every feature. New references continue from the last one used.'**
  String get accountLoadSamplesBody;

  /// No description provided for @accountLoadSamplesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Load samples'**
  String get accountLoadSamplesConfirm;

  /// No description provided for @accountSamplesLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample shipments loaded.'**
  String get accountSamplesLoaded;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutDraft.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished load will be kept as a saved draft for next time.'**
  String get accountSignOutDraft;

  /// No description provided for @accountSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to manage your shipments.'**
  String get accountSignOutBody;

  /// No description provided for @individualShipper.
  ///
  /// In en, this message translates to:
  /// **'Individual shipper'**
  String get individualShipper;

  /// No description provided for @profileNote.
  ///
  /// In en, this message translates to:
  /// **'Carriers see your name and company on the loads you post.'**
  String get profileNote;

  /// No description provided for @profilePhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'You can log in with this number.'**
  String get profilePhoneHelper;

  /// No description provided for @profileEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in email. Contact support to change it.'**
  String get profileEmailHelper;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @feedbackMin.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little more (at least 10 characters).'**
  String get feedbackMin;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback has been sent.'**
  String get feedbackSent;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We read every message.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get feedbackProblem;

  /// No description provided for @feedbackIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get feedbackIdea;

  /// No description provided for @feedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get feedbackQuestion;

  /// No description provided for @feedbackProblemHint.
  ///
  /// In en, this message translates to:
  /// **'What happened, and what did you expect?'**
  String get feedbackProblemHint;

  /// No description provided for @feedbackIdeaHint.
  ///
  /// In en, this message translates to:
  /// **'What would make LODBOD better for you?'**
  String get feedbackIdeaHint;

  /// No description provided for @feedbackQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to know?'**
  String get feedbackQuestionHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked'**
  String get helpFaq;

  /// No description provided for @helpQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I post a load?'**
  String get helpQ1;

  /// No description provided for @helpA1.
  ///
  /// In en, this message translates to:
  /// **'Tap Post Load, enter the route and pickup time, describe the cargo and choose a vehicle. Review it and post. Carriers can bid straight away.'**
  String get helpA1;

  /// No description provided for @helpQ2.
  ///
  /// In en, this message translates to:
  /// **'Why can I only have 3 open requests?'**
  String get helpQ2;

  /// No description provided for @helpA2.
  ///
  /// In en, this message translates to:
  /// **'From the mobile app you can have up to {max} requests that are awaiting bids, confirmed, scheduled or in transit at once. Delivered, cancelled and expired requests free up a slot. For more volume, use the LODBOD web platform.'**
  String helpA2(int max);

  /// No description provided for @helpQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I choose a bid?'**
  String get helpQ3;

  /// No description provided for @helpA3.
  ///
  /// In en, this message translates to:
  /// **'Open your shipment and tap Compare bids. You can sort by price, rating or delivery time and open any offer for details. Nothing is booked until you confirm.'**
  String get helpA3;

  /// No description provided for @helpQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a shipment?'**
  String get helpQ4;

  /// No description provided for @helpA4.
  ///
  /// In en, this message translates to:
  /// **'Yes, until pickup. Open the shipment, tap the ⋮ menu and choose Cancel shipment. Open bids are declined.'**
  String get helpA4;

  /// No description provided for @helpQ5.
  ///
  /// In en, this message translates to:
  /// **'Where is my truck?'**
  String get helpQ5;

  /// No description provided for @helpA5.
  ///
  /// In en, this message translates to:
  /// **'Booked shipments have a Track shipment screen with the route, checkpoints and estimated arrival. In this version tracking is simulated from the schedule.'**
  String get helpA5;

  /// No description provided for @helpQ6.
  ///
  /// In en, this message translates to:
  /// **'Will I lose an unfinished load?'**
  String get helpQ6;

  /// No description provided for @helpA6.
  ///
  /// In en, this message translates to:
  /// **'No. Drafts are saved to your account when you close Post Load or tap Save draft, so you can finish them later.'**
  String get helpA6;

  /// No description provided for @helpStillNeed.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpStillNeed;

  /// No description provided for @helpStillNeedBody.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and the team will get back to you.'**
  String get helpStillNeedBody;

  /// No description provided for @helpMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get helpMessage;

  /// No description provided for @legalSummaryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Summary · updated 8 Nov 2026'**
  String get legalSummaryUpdated;

  /// No description provided for @legalT1.
  ///
  /// In en, this message translates to:
  /// **'Using LODBOD'**
  String get legalT1;

  /// No description provided for @legalT1Body.
  ///
  /// In en, this message translates to:
  /// **'LODBOD connects shippers with independent carriers. You must provide accurate details about your loads, routes and contacts.'**
  String get legalT1Body;

  /// No description provided for @legalT2.
  ///
  /// In en, this message translates to:
  /// **'Posting loads'**
  String get legalT2;

  /// No description provided for @legalT2Body.
  ///
  /// In en, this message translates to:
  /// **'A posted load is an invitation for carriers to bid. Mobile accounts can have up to 3 open requests at a time; additional requests can be created on the LODBOD web platform.'**
  String get legalT2Body;

  /// No description provided for @legalT3.
  ///
  /// In en, this message translates to:
  /// **'Bids and bookings'**
  String get legalT3;

  /// No description provided for @legalT3Body.
  ///
  /// In en, this message translates to:
  /// **'A booking is made only when you accept a bid and confirm it. Accepting one bid declines the others for that load.'**
  String get legalT3Body;

  /// No description provided for @legalT4.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get legalT4;

  /// No description provided for @legalT4Body.
  ///
  /// In en, this message translates to:
  /// **'You can cancel a request before pickup. Repeated late cancellations may affect your access.'**
  String get legalT4Body;

  /// No description provided for @legalT5.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get legalT5;

  /// No description provided for @legalT5Body.
  ///
  /// In en, this message translates to:
  /// **'Fares are agreed between you and the carrier in Nepali rupees. Payment terms are shown before you confirm a booking.'**
  String get legalT5Body;

  /// No description provided for @legalP1.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get legalP1;

  /// No description provided for @legalP1Body.
  ///
  /// In en, this message translates to:
  /// **'Your name, phone number, email, company, and the details of loads you post, bids you receive and bookings you make.'**
  String get legalP1Body;

  /// No description provided for @legalP2.
  ///
  /// In en, this message translates to:
  /// **'How we use it'**
  String get legalP2;

  /// No description provided for @legalP2Body.
  ///
  /// In en, this message translates to:
  /// **'To run your account, show your loads to carriers, process bookings, send service messages and improve LODBOD.'**
  String get legalP2Body;

  /// No description provided for @legalP3.
  ///
  /// In en, this message translates to:
  /// **'What carriers see'**
  String get legalP3;

  /// No description provided for @legalP3Body.
  ///
  /// In en, this message translates to:
  /// **'Carriers see your company name, the route, cargo and schedule. Your phone number is shared only with the carrier you book.'**
  String get legalP3Body;

  /// No description provided for @legalP4.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get legalP4;

  /// No description provided for @legalP4Body.
  ///
  /// In en, this message translates to:
  /// **'You can update your profile at any time and control in-app alerts from Account.'**
  String get legalP4Body;

  /// No description provided for @legalP5.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get legalP5;

  /// No description provided for @legalP5Body.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored with industry-standard encryption in transit and at rest.'**
  String get legalP5Body;

  /// No description provided for @trackEstimatedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Estimated from schedule · live updates unavailable'**
  String get trackEstimatedUnavailable;

  /// No description provided for @trackSimulatedSample.
  ///
  /// In en, this message translates to:
  /// **'Simulated tracking · sample route'**
  String get trackSimulatedSample;

  /// No description provided for @trackJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get trackJustNow;

  /// No description provided for @trackSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{s}s ago'**
  String trackSecondsAgo(int s);

  /// No description provided for @trackLiveLine.
  ///
  /// In en, this message translates to:
  /// **'Live · simulated driver · {age}'**
  String trackLiveLine(String age);

  /// No description provided for @trackStopped.
  ///
  /// In en, this message translates to:
  /// **' · Stopped'**
  String get trackStopped;

  /// No description provided for @trackSpeed.
  ///
  /// In en, this message translates to:
  /// **' · {kmh} km/h'**
  String trackSpeed(int kmh);

  /// No description provided for @trackAtDestination.
  ///
  /// In en, this message translates to:
  /// **'At {place} · waiting for the carrier to confirm delivery'**
  String trackAtDestination(String place);

  /// No description provided for @trackExpectedLate.
  ///
  /// In en, this message translates to:
  /// **'Expected {when} · {km} km remaining'**
  String trackExpectedLate(String when, int km);

  /// No description provided for @trackRemaining.
  ///
  /// In en, this message translates to:
  /// **'{prefix}{km} km remaining{speed}'**
  String trackRemaining(String prefix, int km, String speed);

  /// No description provided for @trackAwaitingPickup.
  ///
  /// In en, this message translates to:
  /// **'Awaiting pickup'**
  String get trackAwaitingPickup;

  /// No description provided for @trackPickupTrip.
  ///
  /// In en, this message translates to:
  /// **'Pickup {when} · {km} km trip'**
  String trackPickupTrip(String when, int km);

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'{place} · {pct}%'**
  String trackProgress(String place, int pct);

  /// No description provided for @trackRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get trackRoute;

  /// No description provided for @trackPickupLine.
  ///
  /// In en, this message translates to:
  /// **'Pickup · {when}'**
  String trackPickupLine(String when);

  /// No description provided for @trackEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated {when}'**
  String trackEstimated(String when);

  /// No description provided for @trackPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get trackPassed;

  /// No description provided for @trackUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get trackUpcoming;

  /// No description provided for @trackFastForward.
  ///
  /// In en, this message translates to:
  /// **'Simulate: fast-forward ×{factor}'**
  String trackFastForward(int factor);

  /// No description provided for @trackEnRoute.
  ///
  /// In en, this message translates to:
  /// **'En route'**
  String get trackEnRoute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
