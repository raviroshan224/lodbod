// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get back => 'पछाडि';

  @override
  String get close => 'बन्द';

  @override
  String get more => 'थप';

  @override
  String get matches => 'मिल्छ';

  @override
  String get shipmentTitle => 'ढुवानी';

  @override
  String get carrier => 'ढुवानीकर्ता';

  @override
  String get arrived => 'पुग्यो';

  @override
  String get appTitle => 'LODBOD शिपर';

  @override
  String get appShipper => 'शिपर';

  @override
  String get appCouldNotStart => 'LODBOD सुरु हुन सकेन';

  @override
  String get appCheckConnectionRestart =>
      'कृपया इन्टरनेट जडान जाँच गरी एप फेरि खोल्नुहोस्।';

  @override
  String get appShipperOnly =>
      'यो एप शिपर खाताका लागि हो। ढुवानीकर्ताले LODBOD Carrier एप प्रयोग गर्छन्।';

  @override
  String appVersionLine(String version) {
    return 'LODBOD शिपर · संस्करण $version';
  }

  @override
  String get errRequestLimit =>
      'तपाईंले मोबाइलबाट ३ अनुरोधको सीमा पुर्‍याउनुभयो। थप अनुरोध बनाउन कृपया LODBOD वेब प्लेटफर्म प्रयोग गर्नुहोस्।';

  @override
  String get errBidAlreadyAccepted =>
      'यो ढुवानीका लागि एउटा बिड पहिले नै स्वीकार भइसकेको छ।';

  @override
  String get errInvalidCredentials =>
      'फोन/इमेल वा पासवर्ड मिलेन। फेरि प्रयास गर्नुहोस्।';

  @override
  String get errEmailTaken =>
      'यो इमेलमा पहिले नै खाता छ। लगइन गरेर हेर्नुहोस्।';

  @override
  String get errPhoneTaken => 'यो फोन नम्बर अर्को खातासँग जोडिएको छ।';

  @override
  String get errWeakPassword =>
      'बलियो पासवर्ड छान्नुहोस्: कम्तीमा ८ अक्षर र एउटा अङ्क।';

  @override
  String get errTooManyAttempts =>
      'धेरै पटक प्रयास भयो। केही मिनेट पर्खेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get errAccountDisabled =>
      'यो खाता निष्क्रिय गरिएको छ। LODBOD सहयोगमा सम्पर्क गर्नुहोस्।';

  @override
  String get errSignInUnavailable =>
      'अहिले साइन-इन उपलब्ध छैन। पछि फेरि प्रयास गर्नुहोस्।';

  @override
  String get errOffline =>
      'LODBOD सँग जडान हुन सकेन। इन्टरनेट जाँच गरी फेरि प्रयास गर्नुहोस्। फेरि प्रयास गर्दा दोहोरो प्रविष्टि हुँदैन।';

  @override
  String get errNoAccess =>
      'तपाईंलाई यसको पहुँच छैन। साइन आउट गरेर फेरि साइन इन गर्नुहोस्।';

  @override
  String get errUnknown => 'केही गडबड भयो। फेरि प्रयास गर्नुहोस्।';

  @override
  String get errRecordGone => 'त्यो रेकर्ड अब उपलब्ध छैन।';

  @override
  String get errShipmentGone => 'यो ढुवानी अब उपलब्ध छैन।';

  @override
  String get errBidGone => 'यो बिड अब उपलब्ध छैन।';

  @override
  String errShipmentNotAcceptingBids(String status) {
    return 'यो ढुवानीले अब बिड लिँदैन ($status)।';
  }

  @override
  String get errPickupPassedRepost =>
      'यस अनुरोधको पिकअप समय बितिसक्यो। नयाँ मिति राखेर फेरि पोस्ट गर्नुहोस्।';

  @override
  String get errOnlyAwaitingBidsReceive =>
      'बिड पर्खिरहेका ढुवानीले मात्र बिड पाउन सक्छन्।';

  @override
  String get errAlreadyHasBids => 'यो ढुवानीमा पहिले नै बिड छन्।';

  @override
  String get errAccountNotSetUp =>
      'तपाईंको खाता अझै तयार छैन। साइन आउट गरेर फेरि साइन इन गर्नुहोस्।';

  @override
  String errCannotTransition(String to, String status) {
    return 'यो ढुवानी $status भएकाले $to गर्न सकिँदैन।';
  }

  @override
  String errNoCarrierUpdate(String status) {
    return '\"$status\" मा कुनै ढुवानीकर्ता अपडेट लागू हुँदैन।';
  }

  @override
  String get errUpdatedElsewhere =>
      'यो ढुवानी अन्यत्रबाट अपडेट भयो। पछिल्लो स्थिति हेर्नुहोस्।';

  @override
  String errCouldNotOpenDialer(String phone) {
    return 'फोन एप खोल्न सकिएन। नम्बर +977 $phone हो।';
  }

  @override
  String get errCouldNotLoad => 'लोड गर्न सकिएन';

  @override
  String get unknownStatus => 'अज्ञात स्थिति';

  @override
  String get unknownState => 'अज्ञात अवस्थामा';

  @override
  String get timelinePosted => 'मोबाइल एपबाट अनुरोध पोस्ट गरियो';

  @override
  String get timelineCancelledByShipper => 'शिपरले रद्द गर्नुभयो';

  @override
  String get timelineExpired => 'म्याद सकियो: बुकिङ नहुँदै पिकअप समय बित्यो';

  @override
  String timelineBidAccepted(String carrier) {
    return '$carrier को बिड स्वीकार गरियो';
  }

  @override
  String get timelineScheduledSim =>
      'ढुवानीकर्ताले पिकअप तालिका बनायो (नक्कली)';

  @override
  String get timelinePickedUpSim => 'माल उठाइयो (नक्कली)';

  @override
  String get timelineDeliveredSim => 'गन्तव्यमा डेलिभर भयो (नक्कली)';

  @override
  String vRequired(String label) {
    return '$label आवश्यक छ';
  }

  @override
  String get vEmailRequired => 'इमेल आवश्यक छ';

  @override
  String get vEmailInvalid => 'सही इमेल लेख्नुहोस्, जस्तै name@company.com';

  @override
  String get vPhoneRequired => 'फोन नम्बर आवश्यक छ';

  @override
  String get vPhoneInvalid =>
      '97 वा 98 बाट सुरु हुने १० अङ्कको मोबाइल नम्बर लेख्नुहोस्';

  @override
  String get vPasswordRequired => 'पासवर्ड आवश्यक छ';

  @override
  String get vPasswordMin => 'पासवर्ड कम्तीमा ८ अक्षरको हुनुपर्छ';

  @override
  String get vNameRequired => 'पूरा नाम आवश्यक छ';

  @override
  String get vNameInvalid => 'आफ्नो पूरा नाम लेख्नुहोस्';

  @override
  String get vPasswordUseEight => 'कम्तीमा ८ अक्षर प्रयोग गर्नुहोस्';

  @override
  String get vPasswordLetterNumber =>
      'कम्तीमा एउटा अक्षर र एउटा अङ्क राख्नुहोस्';

  @override
  String get vIdentifierRequired => 'आफ्नो इमेल वा फोन नम्बर लेख्नुहोस्';

  @override
  String get vPickupRequired => 'पिकअप स्थान आवश्यक छ';

  @override
  String get vPickupInvalid => 'सही पिकअप स्थान लेख्नुहोस्';

  @override
  String get vDestinationRequired => 'गन्तव्य आवश्यक छ';

  @override
  String get vDestinationInvalid => 'सही गन्तव्य लेख्नुहोस्';

  @override
  String get vDestinationSame => 'गन्तव्य पिकअप स्थानभन्दा फरक हुनुपर्छ';

  @override
  String get vPickupDateRequired => 'पिकअप मिति छान्नुहोस्';

  @override
  String get vPickupDatePast => 'पिकअप मिति बितिसकेको हुन सक्दैन';

  @override
  String vPickupDateTooFar(int days) {
    return 'पिकअप आगामी $days दिनभित्र हुनुपर्छ';
  }

  @override
  String get vPickupTimeRequired => 'पिकअप समय छान्नुहोस्';

  @override
  String get vPickupTimePast => 'पिकअप समय बितिसकेको हुन सक्दैन';

  @override
  String get vCategoryRequired => 'मालको प्रकार छान्नुहोस्';

  @override
  String get vDescriptionRequired =>
      'मालको विवरण लेख्नुहोस्, जस्तै \"स्टिल पाइप\"';

  @override
  String get vDescriptionTooLong => 'विवरण ८० अक्षरभित्र राख्नुहोस्';

  @override
  String get vWeightRequired => 'तौल आवश्यक छ';

  @override
  String get vWeightNumber => 'तौल अङ्कमा लेख्नुहोस्';

  @override
  String get vWeightPositive => 'तौल ० भन्दा बढी हुनुपर्छ';

  @override
  String vWeightMax(int tonnes) {
    return 'प्रति अनुरोध बढीमा $tonnes टन';
  }

  @override
  String get vVehicleRequired => 'सवारीको प्रकार छान्नुहोस्';

  @override
  String get vFareWhole => 'भाडा पूरा रुपैयाँमा लेख्नुहोस्';

  @override
  String get vFarePositive => 'भाडा ० भन्दा बढी हुनुपर्छ';

  @override
  String get vFareTooHigh => 'यो भाडा धेरै देखिन्छ';

  @override
  String get vContactNameTooLong => 'नाम ६० अक्षरभित्र राख्नुहोस्';

  @override
  String get vNotesTooLong => 'टिप्पणी ३०० अक्षरभित्र राख्नुहोस्';

  @override
  String get fmtJustNow => 'भर्खरै';

  @override
  String fmtMinutesAgo(int n) {
    return '$n मिनेट अघि';
  }

  @override
  String fmtHoursAgo(int n) {
    return '$n घण्टा अघि';
  }

  @override
  String fmtDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n दिन अघि',
      one: '१ दिन अघि',
    );
    return '$_temp0';
  }

  @override
  String fmtDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n दिन',
      one: '१ दिन',
    );
    return '$_temp0';
  }

  @override
  String get fmtMonthsShort =>
      'जन,फेब,मार्च,अप्रिल,मे,जुन,जुलाई,अग,सेप्ट,अक्टो,नोभ,डिसे';

  @override
  String get fmtWeekdaysShort => 'सोम,मङ्गल,बुध,बिही,शुक्र,शनि,आइत';

  @override
  String get statusAwaitingBids => 'बिड पर्खँदै';

  @override
  String get statusConfirmed => 'पक्का भयो';

  @override
  String get statusScheduled => 'तालिका बन्यो';

  @override
  String get statusInTransit => 'बाटोमा';

  @override
  String get statusDelivered => 'डेलिभर भयो';

  @override
  String get statusCancelled => 'रद्द भयो';

  @override
  String get statusExpired => 'म्याद सकियो';

  @override
  String statusLabelA11y(String label) {
    return 'स्थिति: $label';
  }

  @override
  String get bidPending => 'खुला';

  @override
  String get bidAccepted => 'स्वीकृत';

  @override
  String get bidNotSelected => 'छनोट भएन';

  @override
  String get filterAll => 'सबै';

  @override
  String get filterActive => 'सक्रिय';

  @override
  String get filterCompleted => 'सम्पन्न';

  @override
  String get filterClosed => 'रद्द / म्याद सकिएका';

  @override
  String get sortNewest => 'नयाँ पहिले';

  @override
  String get sortPickupDate => 'पिकअप मिति';

  @override
  String get sortStatus => 'स्थिति';

  @override
  String get cargoCement => 'सिमेन्ट';

  @override
  String get cargoSteel => 'स्टिल';

  @override
  String get cargoConstruction => 'निर्माण सामग्री';

  @override
  String get cargoFoodGrains => 'खाद्यान्न';

  @override
  String get cargoFmcg => 'FMCG';

  @override
  String get cargoFurniture => 'फर्निचर';

  @override
  String get cargoElectronics => 'इलेक्ट्रोनिक्स';

  @override
  String get cargoOther => 'अन्य';

  @override
  String get vehicleOpen => 'खुला ट्रक';

  @override
  String get vehicleClosed => 'बन्द ट्रक';

  @override
  String get vehicleTrailer => 'ट्रेलर';

  @override
  String get vehicleContainer => 'कन्टेनर';

  @override
  String get vehicleTanker => 'ट्याङ्कर';

  @override
  String get vehicleTipper => 'टिपर';

  @override
  String get vehicleMini => 'मिनी ट्रक';

  @override
  String get unitTonnes => 'टन';

  @override
  String get unitKilograms => 'किलोग्राम';

  @override
  String get unitTonneSymbol => 'टन';

  @override
  String get unitKgSymbol => 'किलो';

  @override
  String get stepRoute => 'रुट';

  @override
  String get stepCargo => 'माल';

  @override
  String get stepVehicle => 'सवारी';

  @override
  String get stepReview => 'समीक्षा';

  @override
  String get stepRouteTitle => 'रुट र तालिका';

  @override
  String get stepCargoTitle => 'मालको विवरण';

  @override
  String get stepVehicleTitle => 'सवारी र सम्पर्क';

  @override
  String stepOf(int n, int total) {
    return 'चरण $n / $total';
  }

  @override
  String stepOfA11y(int n, int total, String title) {
    return 'चरण $n / $total: $title';
  }

  @override
  String get completed => 'पूरा भयो';

  @override
  String get period30 => '३० दिन';

  @override
  String get period90 => '९० दिन';

  @override
  String get periodAll => 'सबै समय';

  @override
  String get navHome => 'गृह';

  @override
  String get navShipments => 'ढुवानी';

  @override
  String get navPostLoad => 'लोड पोस्ट';

  @override
  String get navAnalytics => 'तथ्याङ्क';

  @override
  String get navAccount => 'खाता';

  @override
  String get navPostNewLoad => 'नयाँ लोड पोस्ट गर्नुहोस्';

  @override
  String navNeedAttention(String label, int n) {
    return '$label, $n मा ध्यान चाहिन्छ';
  }

  @override
  String badgeNew(String label, int n) {
    return '$label, $n नयाँ';
  }

  @override
  String get actionTryAgain => 'फेरि प्रयास';

  @override
  String get actionNotNow => 'अहिले होइन';

  @override
  String get actionGoBack => 'पछाडि';

  @override
  String get actionGotIt => 'बुझेँ';

  @override
  String get actionSignOut => 'साइन आउट';

  @override
  String get actionLogIn => 'लगइन';

  @override
  String get actionCreateAccount => 'खाता खोल्नुहोस्';

  @override
  String get actionSaveChanges => 'परिवर्तन सुरक्षित गर्नुहोस्';

  @override
  String get actionSaveDraft => 'ड्राफ्ट सुरक्षित';

  @override
  String get actionPostLoad => 'लोड पोस्ट गर्नुहोस्';

  @override
  String get actionPostALoad => 'लोड पोस्ट गर्नुहोस्';

  @override
  String get actionSeeAll => 'सबै हेर्नुहोस्';

  @override
  String get actionEdit => 'सम्पादन';

  @override
  String get actionDetails => 'विवरण';

  @override
  String get actionAccept => 'स्वीकार';

  @override
  String get actionKeepIt => 'राख्नुहोस्';

  @override
  String get actionCancelShipment => 'ढुवानी रद्द गर्नुहोस्';

  @override
  String get actionCancelRequest => 'अनुरोध रद्द गर्नुहोस्';

  @override
  String get actionViewBids => 'बिड हेर्नुहोस्';

  @override
  String get actionTrackShipment => 'ढुवानी ट्र्याक';

  @override
  String get actionPostSimilar => 'यस्तै लोड पोस्ट गर्नुहोस्';

  @override
  String get actionCopyReference => 'सन्दर्भ नम्बर कपी';

  @override
  String get actionMoreActions => 'थप कार्य';

  @override
  String get actionCompareBids => 'बिड तुलना गर्नुहोस्';

  @override
  String get actionHowItWorks => 'कसरी काम गर्छ';

  @override
  String get actionManageRequests => 'अनुरोध व्यवस्थापन';

  @override
  String get actionViewMyRequests => 'मेरा अनुरोध हेर्नुहोस्';

  @override
  String get actionBackToLogIn => 'लगइनमा फर्कनुहोस्';

  @override
  String get actionResendEmail => 'इमेल फेरि पठाउनुहोस्';

  @override
  String get actionSkipForNow => 'अहिलेलाई छोड्नुहोस्';

  @override
  String get actionContinue => 'अगाडि बढ्नुहोस्';

  @override
  String get actionClearSearch => 'खोज खाली गर्नुहोस्';

  @override
  String get actionClearSearchFilters => 'खोज र फिल्टर खाली गर्नुहोस्';

  @override
  String get actionStartOver => 'फेरि सुरु';

  @override
  String get actionClearForm => 'फारम खाली गर्नुहोस्';

  @override
  String get actionKeepEditing => 'सम्पादन जारी राख्नुहोस्';

  @override
  String get actionReviewRequest => 'अनुरोध समीक्षा';

  @override
  String actionContinueTo(String step) {
    return '$step मा जानुहोस्';
  }

  @override
  String get optional => '(ऐच्छिक)';

  @override
  String get fieldFullName => 'पूरा नाम';

  @override
  String get fieldPhone => 'फोन नम्बर';

  @override
  String get fieldEmail => 'इमेल';

  @override
  String get fieldEmailOrPhone => 'इमेल वा फोन नम्बर';

  @override
  String get fieldPassword => 'पासवर्ड';

  @override
  String get fieldCompany => 'कम्पनीको नाम';

  @override
  String get hintName => 'जस्तै आरव श्रेष्ठ';

  @override
  String get hintCompany => 'जस्तै हिमाल ट्रेडर्स प्रा. लि.';

  @override
  String get hintEmail => 'you@company.com';

  @override
  String get hintEmailOrPhone => 'you@company.com वा 98XXXXXXXX';

  @override
  String get showPassword => 'पासवर्ड देखाउनुहोस्';

  @override
  String get hidePassword => 'पासवर्ड लुकाउनुहोस्';

  @override
  String get passwordHint => 'कम्तीमा ८ अक्षर, एउटा अक्षर र एउटा अङ्क सहित';

  @override
  String get passwordWeak => 'कमजोर पासवर्ड';

  @override
  String get passwordGood => 'ठीकै पासवर्ड';

  @override
  String get passwordStrong => 'बलियो पासवर्ड';

  @override
  String get loginTitle => 'फेरि स्वागत छ';

  @override
  String get loginSubtitle =>
      'आफ्ना लोड र ढुवानी व्यवस्थापन गर्न लगइन गर्नुहोस्।';

  @override
  String get loginForgot => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get loginNoAccount => 'खाता छैन?';

  @override
  String get legalByContinuing => 'अगाडि बढेर तपाईं ';

  @override
  String get legalIAgree => 'म ';

  @override
  String get legalAnd => ' र ';

  @override
  String get legalTerms => 'सेवाका सर्तहरू';

  @override
  String get legalPrivacy => 'गोपनीयता नीति';

  @override
  String get registerTitle => 'खाता खोल्नुहोस्';

  @override
  String get registerSubtitle =>
      'मिनेटभरमै लोड पोस्ट गर्नुहोस् र ढुवानीकर्ताका बिड तुलना गर्नुहोस्।';

  @override
  String get registerVerifyHelper => 'प्रमाणीकरण लिङ्क यहीँ पठाइनेछ।';

  @override
  String get registerAcceptTerms =>
      'खाता खोल्न कृपया सर्तहरू स्वीकार गर्नुहोस्';

  @override
  String get registerHaveAccount => 'पहिले नै खाता छ?';

  @override
  String get forgotTitle => 'पासवर्ड रिसेट गर्नुहोस्';

  @override
  String get forgotSubtitle =>
      'खातामा भएको इमेल वा फोन नम्बर लेख्नुहोस्; नयाँ पासवर्ड राख्ने लिङ्क इमेलमा पठाउनेछौँ।';

  @override
  String get forgotSend => 'रिसेट लिङ्क पठाउनुहोस्';

  @override
  String get forgotRemembered => 'सम्झनुभयो?';

  @override
  String get forgotSentTitle => 'इमेल जाँच गर्नुहोस्';

  @override
  String forgotSentBody(String identifier) {
    return '$identifier को खाता छ भने पासवर्ड रिसेट लिङ्क पठाइएको छ। एक मिनेट लाग्न सक्छ; नआए स्प्याम फोल्डर हेर्नुहोस्।';
  }

  @override
  String get forgotUseDifferent => 'अर्को इमेल वा फोन प्रयोग गर्नुहोस्';

  @override
  String get verifyTitle => 'इमेल प्रमाणित गर्नुहोस्';

  @override
  String get verifySentTo => 'हामीले प्रमाणीकरण लिङ्क पठाएका छौँ: ';

  @override
  String get verifyOpenIt => '। खाता सक्रिय गर्न लिङ्क खोल्नुहोस्।';

  @override
  String get verifyDone => 'मैले इमेल प्रमाणित गरेँ';

  @override
  String get verifyDidntGet => 'आएन?';

  @override
  String verifyResendIn(String seconds) {
    return '0:$seconds पछि फेरि पठाउनुहोस्';
  }

  @override
  String get verifySuccess => 'इमेल प्रमाणित भयो। LODBOD मा स्वागत छ!';

  @override
  String get verifyNotYet =>
      'अझै पुष्टि हुन सकेन। इमेलको लिङ्क खोलेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get verifyResent => 'प्रमाणीकरण इमेल फेरि पठाइयो।';

  @override
  String get verifyLinkSent => 'प्रमाणीकरण लिङ्क पठाइयो। इनबक्स हेर्नुहोस्।';

  @override
  String get completeTitle => 'सेटअप पूरा गर्नुहोस्';

  @override
  String get completeSubtitle =>
      'ढुवानीकर्ताले कोसँग काम गर्दैछन् भनी बुझ्न आफ्नो परिचय दिनुहोस्।';

  @override
  String get splashChecking => 'सेसन जाँच हुँदैछ…';

  @override
  String get splashLoadFailed => 'तपाईंको खाता लोड गर्न सकिएन';

  @override
  String get homeGoodMorning => 'शुभ प्रभात,';

  @override
  String get homeGoodAfternoon => 'शुभ दिउँसो,';

  @override
  String get homeGoodEvening => 'शुभ साँझ,';

  @override
  String get homeShipNew => 'नयाँ माल पठाउनुहोस्';

  @override
  String get homeRequestsUsed => 'प्रयोग भएका मोबाइल अनुरोध: ';

  @override
  String homeUsedOf(int used, int limit) {
    return '$limit मध्ये $used';
  }

  @override
  String homeUsedOfInUse(int used, int limit) {
    return '$limit मध्ये $used प्रयोगमा';
  }

  @override
  String homeRequestsInUseA11y(int used, int limit) {
    return '$limit मध्ये $used मोबाइल अनुरोध प्रयोगमा';
  }

  @override
  String homeAllInUse(int limit) {
    return 'सबै $limit प्रयोगमा छन्। नयाँ लोड पोस्ट गर्न एउटा सम्पन्न वा रद्द गर्नुहोस्। ';
  }

  @override
  String get homeNeedsAction => 'तपाईंको निर्णय चाहिन्छ';

  @override
  String homeBidsOn(int n, String reference) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$reference मा $n बिड',
      one: '$reference मा १ बिड',
    );
    return '$_temp0';
  }

  @override
  String homeRoutePickup(String route, String date) {
    return '$route · पिकअप $date';
  }

  @override
  String get homeOnTheRoad => 'बाटोमा';

  @override
  String get homeNextPickup => 'अर्को पिकअप';

  @override
  String get homeOtherShipments => 'अन्य ढुवानी';

  @override
  String homeSeeAllN(int n) {
    return 'सबै $n ढुवानी हेर्नुहोस्';
  }

  @override
  String homeStatA11y(int count, String label) {
    return '$count $label। यी ढुवानी देखाउनुहोस्';
  }

  @override
  String homeLeft(String place) {
    return '$place बाट हिँड्यो';
  }

  @override
  String homePassed(String place) {
    return '$place पार गर्‍यो';
  }

  @override
  String homeKmLeft(String where, int km) {
    return '$where · $km कि.मी. बाँकी';
  }

  @override
  String get runningLate => 'ढिलो हुँदैछ';

  @override
  String etaTime(String time) {
    return 'पुग्ने समय $time';
  }

  @override
  String get simulatedTracking => 'नक्कली ट्र्याकिङ';

  @override
  String get homeSamplesAdded => 'नमुना ढुवानी थपियो। घुमेर हेर्नुहोस्!';

  @override
  String get homeSamplesFailed =>
      'नमुना ढुवानी थप्न सकिएन। फेरि प्रयास गर्नुहोस्।';

  @override
  String get homeWelcome => 'LODBOD मा स्वागत छ';

  @override
  String get homeWelcomeBody =>
      'भरपर्दा ढुवानीकर्तासँग नेपालभर माल पठाउनुहोस्। यसरी काम गर्छ:';

  @override
  String get homeStep1 => 'लोड पोस्ट गर्नुहोस्';

  @override
  String get homeStep1Body => 'रुट, माल र ट्रक—एक मिनेटभित्रै।';

  @override
  String get homeStep2 => 'बिड तुलना गर्नुहोस्';

  @override
  String get homeStep2Body =>
      'प्रमाणित ढुवानीकर्ताले तुलना गर्न मिल्ने प्रस्ताव पठाउँछन्।';

  @override
  String get homeStep3 => 'डेलिभरी ट्र्याक गर्नुहोस्';

  @override
  String get homeStep3Body => 'डेलिभर नहुँदासम्म हरेक चरण हेर्नुहोस्।';

  @override
  String get homePostFirst => 'पहिलो लोड पोस्ट गर्नुहोस्';

  @override
  String get homeExploreSamples => 'नमुना ढुवानीसँग घुमेर हेर्नुहोस्';

  @override
  String get homeLoading => 'तपाईंका ढुवानी लोड हुँदैछन्';

  @override
  String get shipmentsSort => 'ढुवानी क्रमबद्ध गर्नुहोस्';

  @override
  String shipmentsSortBy(String sort) {
    return 'क्रम: $sort';
  }

  @override
  String get shipmentsSearchHint => 'सन्दर्भ, रुट वा माल खोज्नुहोस्';

  @override
  String shipmentsCount(int n, String sort) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ढुवानी',
      one: '१ ढुवानी',
    );
    return '$_temp0 · $sort';
  }

  @override
  String get shipmentsNoMatch => 'मिल्ने ढुवानी भेटिएन';

  @override
  String get shipmentsNoMatchBody => 'अर्को सन्दर्भ, सहर वा स्थिति खोज्नुहोस्।';

  @override
  String get shipmentsEmpty => 'अहिलेसम्म ढुवानी छैन';

  @override
  String get shipmentsEmptyBody =>
      'लोड पोस्ट गर्नुहोस्, ढुवानीकर्ताले बिड गर्न थाल्छन्।';

  @override
  String cardA11y(String reference, String status, String from, String to) {
    return '$reference, $status, $from देखि $to';
  }

  @override
  String cardPosted(String when) {
    return '$when पोस्ट गरिएको';
  }

  @override
  String get cardWaitingForBids => 'बिड पर्खँदै';

  @override
  String cardBids(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n बिड',
      one: '१ बिड',
    );
    return '$_temp0';
  }

  @override
  String get cardFarePending => 'भाडा तय हुन बाँकी';

  @override
  String cardBudget(String amount) {
    return 'बजेट $amount';
  }

  @override
  String cardStatusWhen(String status, String when) {
    return '$status $when';
  }

  @override
  String cardDeliveredOn(String date) {
    return '$date मा डेलिभर';
  }

  @override
  String get cardCarrierAssigned => 'ढुवानीकर्ता तोकियो';

  @override
  String cardPickupAt(String time) {
    return 'पिकअप $time';
  }

  @override
  String get onTheWay => 'बाटोमा';

  @override
  String cardPickedUp(String when) {
    return '$when उठाइयो';
  }

  @override
  String routeAtoB(String from, String to) {
    return '$from देखि $to';
  }

  @override
  String get timelinePostedStep => 'पोस्ट';

  @override
  String get timelineBookedStep => 'बुक';

  @override
  String timelineA11y(String status) {
    return 'ढुवानी $status';
  }

  @override
  String timelineStepA11y(int n, String label) {
    return 'चरण $n / 5: $label';
  }

  @override
  String detailsPosted(String date) {
    return '$date मा पोस्ट';
  }

  @override
  String get detailsNotFound => 'ढुवानी भेटिएन';

  @override
  String get detailsNotFoundBody =>
      'यो हटाइएको हुन सक्छ। आफ्ना ढुवानीमा फर्कनुहोस्।';

  @override
  String get detailsRemoved => 'यो हटाइएको हुन सक्छ।';

  @override
  String detailsPickupLine(String when) {
    return 'पिकअप · $when';
  }

  @override
  String detailsDeliveredLine(String when) {
    return 'डेलिभर · $when';
  }

  @override
  String detailsEtaLine(String when) {
    return 'अनुमानित आगमन · $when';
  }

  @override
  String get detailsSection => 'ढुवानी विवरण';

  @override
  String get detailsCargo => 'माल';

  @override
  String get detailsWeight => 'तौल';

  @override
  String get detailsVehicle => 'सवारी';

  @override
  String get detailsYourBudget => 'तपाईंको बजेट';

  @override
  String get openToBids => 'बिडका लागि खुला';

  @override
  String get detailsContactSection => 'पिकअप सम्पर्क र टिप्पणी';

  @override
  String get detailsContact => 'सम्पर्क';

  @override
  String get detailsPhone => 'फोन';

  @override
  String get detailsNotes => 'टिप्पणी';

  @override
  String detailsCall(String name) {
    return '$name लाई फोन गर्नुहोस्';
  }

  @override
  String get contact => 'सम्पर्क व्यक्ति';

  @override
  String get detailsActivity => 'गतिविधि';

  @override
  String get detailsDropOff => 'ड्रप-अफ';

  @override
  String detailsCarriersHaveBid(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ढुवानीकर्ताले बिड गरे',
      one: '१ ढुवानीकर्ताले बिड गरे',
    );
    return '$_temp0';
  }

  @override
  String get detailsFindingCarriers => 'ढुवानीकर्ता खोज्दै…';

  @override
  String get detailsCompareBody =>
      'मूल्य, रेटिङ र डेलिभरी समय तुलना गरेर एउटा बुक गर्नुहोस्।';

  @override
  String get detailsVisibleBody =>
      'तपाईंको लोड ढुवानीकर्ताले देख्छन्। बिड प्रायः केही मिनेटमै आउँछन्।';

  @override
  String get detailsCancelledTitle => 'यो अनुरोध रद्द गरियो';

  @override
  String get detailsExpiredTitle => 'यो अनुरोधको म्याद सकियो';

  @override
  String get detailsClosedBody =>
      'यो अब मोबाइल अनुरोध सीमामा गनिँदैन। एक ट्यापमै फेरि पोस्ट गर्न सक्नुहुन्छ।';

  @override
  String get detailsAgreedFare => 'तय भाडा';

  @override
  String get detailsEstimatedArrival => 'अनुमानित आगमन';

  @override
  String detailsKmToGo(String where, int km) {
    return '$where · $km कि.मी. बाँकी · नक्कली';
  }

  @override
  String get detailsReplaceTitle => 'अधुरो लोड बदल्ने?';

  @override
  String detailsReplaceBody(String reference) {
    return 'तपाईंले भर्दै गरेको लोड छ। $reference बाट सुरु गर्दा त्यो बदलिनेछ।';
  }

  @override
  String get detailsReplaceIt => 'बदल्नुहोस्';

  @override
  String detailsCompareN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n बिड तुलना गर्नुहोस्',
      one: '१ बिड हेर्नुहोस्',
    );
    return '$_temp0';
  }

  @override
  String detailsCancelTitle(String reference) {
    return '$reference रद्द गर्ने?';
  }

  @override
  String get detailsCancelOpenBody =>
      'ढुवानीकर्ताले अब बिड गर्न पाउने छैनन्, र खुला बिड अस्वीकार हुनेछन्।';

  @override
  String detailsCancelBookedBody(String carrier) {
    return '$carrier सँगको बुकिङ रद्द हुनेछ। यसले तपाईंको एउटा मोबाइल अनुरोध खाली गर्छ।';
  }

  @override
  String get theCarrier => 'ढुवानीकर्ता';

  @override
  String detailsCancelled(String reference) {
    return '$reference रद्द गरियो।';
  }

  @override
  String detailsCopied(String reference) {
    return '$reference कपी भयो';
  }

  @override
  String get simCarrierUpdate => 'ढुवानीकर्ता अपडेट नक्कल गर्नुहोस्';

  @override
  String simCarrierUpdateBody(String reference, String status) {
    return '$reference लाई \"$status\" बनाउनुहोस्। वास्तविक सेवामा यो अपडेट ढुवानीकर्ताबाट आउँछ।';
  }

  @override
  String simMark(String status) {
    return '$status बनाउनुहोस्';
  }

  @override
  String simNowStatus(String reference, String status) {
    return '$reference अब $status।';
  }

  @override
  String simMenuMark(String status) {
    return 'नक्कल: $status बनाउनुहोस्';
  }

  @override
  String get simDemoCarrierUpdate => 'डेमो ढुवानीकर्ता अपडेट';

  @override
  String get simBidsNow => 'नक्कल: बिड अहिले आउँछन्';

  @override
  String get simDemoBids => 'डेमो ढुवानीकर्ता बिड';

  @override
  String get simBidsNowDemo => 'बिड अहिले ल्याउनुहोस् (डेमो)';

  @override
  String get bidsTitle => 'बिड';

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
    return 'पिकअप $when · $vehicle';
  }

  @override
  String bidsBudgetLine(String amount) {
    return 'बजेट $amount';
  }

  @override
  String bidsBookedWith(String carrier) {
    return '$carrier सँग बुक भयो';
  }

  @override
  String bidsBookedBody(String fare, String reference, String status) {
    return '$fare · $reference $status।';
  }

  @override
  String bidsClosedBody(String status) {
    return 'यो ढुवानी $status छ र अब बिड लिँदैन।';
  }

  @override
  String bidsOffers(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n प्रस्ताव',
      one: '१ प्रस्ताव',
    );
    return '$_temp0';
  }

  @override
  String get bidsSortBy => 'क्रम';

  @override
  String get bidsSortNewest => 'नयाँ';

  @override
  String get bidsSortPrice => 'मूल्य';

  @override
  String get bidsSortRating => 'रेटिङ';

  @override
  String get bidsSortFastest => 'छिटो';

  @override
  String get bidsWaiting => 'ढुवानीकर्ता पर्खँदै';

  @override
  String get bidsNone => 'बिड छैन';

  @override
  String get bidsWaitingBody =>
      'तपाईंको लोड ढुवानीकर्ताले देख्छन्। प्रस्ताव प्रायः केही मिनेटमै आउँछन्, र हामी सूचित गर्नेछौँ।';

  @override
  String get bidsNoneBody => 'यो ढुवानीमा कुनै बिड आएन।';

  @override
  String bidUnder(String amount) {
    return '$amount कम';
  }

  @override
  String bidOver(String amount) {
    return '$amount बढी';
  }

  @override
  String bidA11y(String carrier, String fare, String days, String rating) {
    return '$carrier, $fare, $days, रेटिङ $rating';
  }

  @override
  String get bidDelivery => 'डेलिभरी';

  @override
  String get bidVehicle => 'सवारी';

  @override
  String bidBy(String date) {
    return '$date सम्म';
  }

  @override
  String bidReceived(String when) {
    return '$when प्राप्त';
  }

  @override
  String bidRatedA11y(String rating, int trips) {
    return '$trips यात्राबाट ५ मा $rating रेटिङ';
  }

  @override
  String bidTrips(int trips) {
    return '  ·  $trips यात्रा';
  }

  @override
  String get offerTitle => 'प्रस्ताव विवरण';

  @override
  String get offerNotFound => 'बिड भेटिएन';

  @override
  String get offerNotFoundBody => 'यो बिड फिर्ता लिइएको हुन सक्छ।';

  @override
  String get offerBooked => 'तपाईंले यो ढुवानीकर्ता बुक गर्नुभयो';

  @override
  String offerBookedBody(String reference, String status, String carrier) {
    return '$reference $carrier सँग $status';
  }

  @override
  String offerNotSelectedBody(String reference) {
    return 'छनोट भएन: $reference का लागि तपाईंले अर्को ढुवानीकर्ता बुक गर्नुभयो।';
  }

  @override
  String offerClosedBody(String reference, String status) {
    return '$reference $status छ, त्यसैले यो प्रस्ताव अब स्वीकार गर्न सकिँदैन।';
  }

  @override
  String get offerFare => 'प्रस्तावित भाडा';

  @override
  String get offerSection => 'प्रस्ताव';

  @override
  String offerAfterPickup(String days) {
    return 'पिकअपपछि $days';
  }

  @override
  String get offerArrivesBy => 'पुग्ने';

  @override
  String offerEstimate(String date) {
    return '$date (अनुमान)';
  }

  @override
  String get offerReceived => 'प्राप्त';

  @override
  String get offerNote => 'टिप्पणी';

  @override
  String get offerYourLoad => 'तपाईंको लोड';

  @override
  String get offerPickup => 'पिकअप';

  @override
  String get offerRequested => 'मागिएको';

  @override
  String get offerMatchesBudget => 'तपाईंको बजेट अनुसार';

  @override
  String offerDiffBudget(String amount, String direction) {
    return 'तपाईंको बजेटभन्दा $amount $direction';
  }

  @override
  String get over => 'बढी';

  @override
  String get under => 'कम';

  @override
  String get offerConfirmNote => 'बुक हुनुअघि तपाईंले पुष्टि गर्नुहुन्छ';

  @override
  String acceptFor(String amount) {
    return '$amount मा स्वीकार';
  }

  @override
  String acceptTitle(String carrier) {
    return '$carrier बुक गर्ने?';
  }

  @override
  String acceptBody(String reference, String others) {
    return 'यसले $reference यो ढुवानीकर्तासँग पक्का गर्छ। $othersएपबाट यो उल्टाउन सकिँदैन।';
  }

  @override
  String acceptOthersDeclined(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'अन्य $n प्रस्ताव अस्वीकार हुनेछन्। ',
      one: 'अर्को प्रस्ताव अस्वीकार हुनेछ। ',
    );
    return '$_temp0';
  }

  @override
  String get acceptRoute => 'रुट';

  @override
  String get acceptFare => 'भाडा';

  @override
  String acceptAbout(String days) {
    return 'करिब $days';
  }

  @override
  String acceptBooked(String reference, String carrier) {
    return 'बुक भयो! $reference $carrier सँग पक्का भयो';
  }

  @override
  String acceptFailed(String message) {
    return '$message प्रस्ताव अझै स्वीकार भएको छैन।';
  }

  @override
  String get postTitle => 'लोड पोस्ट गर्नुहोस्';

  @override
  String postPostingAs(String company) {
    return '$company को रूपमा';
  }

  @override
  String get postResumed => 'छोडेको ठाउँबाट सुरु';

  @override
  String get postDraftSaved =>
      'ड्राफ्ट सुरक्षित भयो। लोड पोस्टबाट जहिले पनि पूरा गर्नुहोस्।';

  @override
  String get postDraftSavedShort => 'ड्राफ्ट सुरक्षित';

  @override
  String get postStartOverTitle => 'फेरि सुरु गर्ने?';

  @override
  String get postStartOverBody =>
      'यो लोडका लागि भरेका सबै कुरा, सुरक्षित ड्राफ्ट सहित, मेटिनेछ।';

  @override
  String get postAllInUse => 'सबै ३ मोबाइल अनुरोध प्रयोगमा छन्';

  @override
  String get postAllInUseBody =>
      'अहिले तयार गर्नुहोस्; एउटा अनुरोध डेलिभर वा रद्द भएपछि पोस्ट गर्नुहोस्।';

  @override
  String get postAllInUseReviewBody =>
      'एउटा अनुरोध डेलिभर वा रद्द भएपछि यो लोड पोस्ट गर्न सक्नुहुनेछ।';

  @override
  String postDoneA11y(String title, String summary) {
    return '$title: $summary। सम्पादन';
  }

  @override
  String get postPickupDate => 'पिकअप मिति';

  @override
  String get postPickupTime => 'पिकअप समय';

  @override
  String get postTimePassed => 'आज त्यो समय बितिसक्यो। पछिको समय छान्नुहोस्।';

  @override
  String get postToday => 'आज';

  @override
  String get postTomorrow => 'भोलि';

  @override
  String get postPlus2Days => '+२ दिन';

  @override
  String get postPickDate => 'मिति छान्नुहोस्';

  @override
  String get postPickupCity => 'पिकअप सहर';

  @override
  String get postDestinationCity => 'गन्तव्य सहर';

  @override
  String get postSwap => 'पिकअप र गन्तव्य साट्नुहोस्';

  @override
  String get postRecent => 'हालैका';

  @override
  String get postMorning => 'बिहान';

  @override
  String get postMidday => 'मध्याह्न';

  @override
  String get postAfternoon => 'दिउँसो';

  @override
  String get postEvening => 'साँझ';

  @override
  String get postExact => 'ठ्याक्कै';

  @override
  String get postPickTime => 'समय छान्नुहोस्';

  @override
  String get postSlotsPassedAll =>
      'आजका सामान्य समय बितिसके। ठ्याक्कै समय वा अर्को दिन छान्नुहोस्।';

  @override
  String get postSlotsPassedSome =>
      'आजका अघिल्ला समय बितिसके। पछिको समय वा ठ्याक्कै समय छान्नुहोस्।';

  @override
  String get postMaterial => 'सामग्री';

  @override
  String get postWhatShipping => 'के पठाउँदै हुनुहुन्छ?';

  @override
  String get postWhatShippingHint => 'जस्तै २४० बोरा सिमेन्ट, स्टिल पाइप';

  @override
  String get postTotalWeight => 'कुल तौल';

  @override
  String get postWeightHint => 'जस्तै १२';

  @override
  String get postVehicleType => 'सवारीको प्रकार';

  @override
  String get postYourBudget => 'तपाईंको बजेट';

  @override
  String get postBudgetHelper =>
      'ढुवानीकर्ताले यसलाई सङ्केतका रूपमा हेर्छन् र यसभन्दा माथि वा तल बिड गर्न सक्छन्।';

  @override
  String get postPickupContact => 'पिकअप सम्पर्क';

  @override
  String get postContactHint => 'पिकअप ठाउँमा भेटिने व्यक्तिको नाम';

  @override
  String get postNotes => 'ढुवानीकर्ताका लागि टिप्पणी';

  @override
  String get postNotesHint => 'लोडिङ निर्देशन, प्याकेजिङ, गेट समय…';

  @override
  String get reviewSubtitle => 'पोस्ट गर्नुअघि सबै जाँच्नुहोस्';

  @override
  String get reviewNeedsAttention => 'पोस्ट गर्नुअघि केही विवरण मिलाउनुपर्छ।';

  @override
  String get reviewLimitReached => 'अनुरोध सीमा पुग्यो';

  @override
  String get reviewCouldNotPost => 'लोड पोस्ट गर्न सकिएन';

  @override
  String reviewDetailsSaved(String message) {
    return '$message तपाईंका विवरण सुरक्षित छन्।';
  }

  @override
  String get reviewMaterial => 'सामग्री';

  @override
  String get reviewDescription => 'विवरण';

  @override
  String get reviewWeight => 'तौल';

  @override
  String get reviewVehicle => 'सवारी';

  @override
  String get reviewBudget => 'बजेट';

  @override
  String get reviewContact => 'सम्पर्क';

  @override
  String get reviewPhone => 'फोन';

  @override
  String get reviewNotes => 'टिप्पणी';

  @override
  String reviewUsesRequest(int n, int limit) {
    return 'पोस्ट गर्दा $limit मध्ये $n औँ मोबाइल अनुरोध प्रयोग हुन्छ। ढुवानीकर्ताले तुरुन्तै बिड गर्न थाल्न सक्छन्।';
  }

  @override
  String get postedTitle => 'लोड पोस्ट भयो';

  @override
  String get postedLive => 'तपाईंको अनुरोध सक्रिय छ।';

  @override
  String postedLiveBody(String reference) {
    return '$reference सक्रिय छ। पहिलो बिड आउनासाथ हामी जानकारी दिनेछौँ।';
  }

  @override
  String get postedRequestCreated => 'अनुरोध बनाइयो';

  @override
  String get postedPickup => 'पिकअप';

  @override
  String get postedCargo => 'माल';

  @override
  String get postedVehicle => 'सवारी';

  @override
  String get postedViewRequest => 'अनुरोध र बिड हेर्नुहोस्';

  @override
  String get postedPostAnother => 'अर्को लोड पोस्ट गर्नुहोस्';

  @override
  String get limitTitleReached => 'अनुरोध सीमा पुग्यो';

  @override
  String get limitTitle => 'मोबाइल अनुरोध सीमा';

  @override
  String limitBody(int max, int used, int limit) {
    return 'मोबाइल एपबाट एकपटकमा बढीमा $max खुला अनुरोध राख्न सकिन्छ। तपाईंले $limit मध्ये $used प्रयोग गर्दै हुनुहुन्छ।';
  }

  @override
  String get limitDetailsSaved =>
      'तपाईंका विवरण सुरक्षित छन्। कुनै अनुरोध डेलिभर, रद्द वा म्याद सकिनासाथ पेस गर्न सक्नुहुन्छ।';

  @override
  String get limitCanPost =>
      'कुनै अनुरोध डेलिभर, रद्द वा म्याद सकिनासाथ नयाँ लोड पोस्ट गर्न सक्नुहुन्छ।';

  @override
  String get limitCounts => 'सीमामा गनिन्छ';

  @override
  String get limitDoesNotCount => 'गनिँदैन';

  @override
  String notifNewBid(String reference) {
    return '$reference मा नयाँ बिड';
  }

  @override
  String notifNewBidBody(String carrier, String fare, String days) {
    return '$carrier ले $fare प्रस्ताव गर्‍यो · $days मा डेलिभरी';
  }

  @override
  String notifLive(String reference) {
    return '$reference सक्रिय छ';
  }

  @override
  String notifLiveBody(String route) {
    return '$route · ढुवानीकर्ताले अब बिड गर्न सक्छन्';
  }

  @override
  String notifConfirmed(String reference) {
    return '$reference पक्का भयो';
  }

  @override
  String get notifConfirmedBody => 'ढुवानीकर्ता बुक भयो';

  @override
  String notifScheduled(String reference) {
    return '$reference को पिकअप तालिका बन्यो';
  }

  @override
  String notifScheduledBody(String carrier, String when) {
    return '$carrier · $when';
  }

  @override
  String notifOnTheWay(String reference) {
    return '$reference बाटोमा छ';
  }

  @override
  String notifPickedUpIn(String place) {
    return '$place मा उठाइयो';
  }

  @override
  String notifDelivered(String reference) {
    return '$reference डेलिभर भयो';
  }

  @override
  String notifDeliveredIn(String place) {
    return '$place मा डेलिभर';
  }

  @override
  String notifCancelled(String reference) {
    return '$reference रद्द भयो';
  }

  @override
  String notifExpired(String reference) {
    return '$reference को म्याद सकियो';
  }

  @override
  String get notifExpiredBody => 'पिकअपअघि कुनै ढुवानीकर्ता बुक भएन';

  @override
  String notifNewBidsOn(int n, String reference) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$reference मा $n नयाँ बिड',
      one: '$reference मा नयाँ बिड',
    );
    return '$_temp0';
  }

  @override
  String get notifTitle => 'सूचना';

  @override
  String get notifToday => 'आज';

  @override
  String get notifYesterday => 'हिजो';

  @override
  String get notifEarlier => 'पहिले';

  @override
  String get notifCaughtUp => 'सबै हेरिसक्नुभयो';

  @override
  String get notifCaughtUpBody => 'बिड, बुकिङ र डेलिभरी अपडेट यहाँ देखिनेछन्।';

  @override
  String get notifView => 'हेर्नुहोस्';

  @override
  String get analyticsTitle => 'तथ्याङ्क';

  @override
  String get analyticsSubtitle => 'तपाईंको ढुवानी कस्तो चलिरहेको छ';

  @override
  String get analyticsNoData => 'अहिलेसम्म डेटा छैन';

  @override
  String get analyticsNothingPeriod => 'यस अवधिमा केही छैन';

  @override
  String get analyticsNoDataBody => 'लोड पोस्ट गरेपछि तथ्याङ्क देखिन्छ।';

  @override
  String get analyticsNothingPeriodBody =>
      'गतिविधि हेर्न लामो अवधि छान्नुहोस्।';

  @override
  String analyticsBookedSpend(String period) {
    return 'बुक भएको खर्च · $period';
  }

  @override
  String analyticsBookedLoads(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n बुक लोड',
      one: '१ बुक लोड',
    );
    return '$_temp0';
  }

  @override
  String analyticsAvgPerLoad(String amount) {
    return ' · प्रति लोड औसत $amount';
  }

  @override
  String get analyticsLoadsPosted => 'पोस्ट गरिएका लोड';

  @override
  String analyticsOpenNow(int n) {
    return '$n अहिले खुला';
  }

  @override
  String get analyticsDelivered => 'डेलिभर भएका';

  @override
  String analyticsTonnesMoved(String t) {
    return '$t टन ढुवानी';
  }

  @override
  String get analyticsBidsReceived => 'प्राप्त बिड';

  @override
  String analyticsAcrossLoads(int n) {
    return '$n लोडमा';
  }

  @override
  String get analyticsAvgBids => 'प्रति लोड औसत बिड';

  @override
  String get analyticsPerPostedLoad => 'प्रति पोस्ट लोड';

  @override
  String get analyticsByStatus => 'स्थिति अनुसार ढुवानी';

  @override
  String get analyticsTopRoutes => 'मुख्य रुट';

  @override
  String analyticsLoads(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n लोड',
      one: '१ लोड',
    );
    return '$_temp0';
  }

  @override
  String analyticsStatusA11y(String status, int count) {
    return '$status: $count';
  }

  @override
  String get accountTitle => 'खाता';

  @override
  String accountShipperLine(String company) {
    return '$company · शिपर';
  }

  @override
  String get accountSection => 'खाता';

  @override
  String get accountProfile => 'प्रोफाइल र कम्पनी';

  @override
  String get accountVerify => 'प्रमाणित गर्नुहोस्';

  @override
  String get accountVerified => 'प्रमाणित';

  @override
  String get accountSending => 'पठाउँदै…';

  @override
  String get accountMobileRequests => 'मोबाइल अनुरोध';

  @override
  String get accountPreferences => 'प्राथमिकता';

  @override
  String get accountLanguage => 'भाषा';

  @override
  String get accountAppearance => 'रूप';

  @override
  String get appearanceSystem => 'सिस्टम';

  @override
  String get appearanceLight => 'उज्यालो';

  @override
  String get appearanceDark => 'अँध्यारो';

  @override
  String get accountNotifications => 'सूचना';

  @override
  String get accountNewBidAlerts => 'नयाँ बिड सूचना';

  @override
  String get accountDeliveryUpdates => 'डेलिभरी अपडेट';

  @override
  String get accountSupport => 'सहयोग र प्रतिक्रिया';

  @override
  String get accountHelpCenter => 'सहयोग केन्द्र';

  @override
  String get accountSendFeedback => 'प्रतिक्रिया पठाउनुहोस्';

  @override
  String get accountLegal => 'कानुनी';

  @override
  String get accountDemo => 'डेमो';

  @override
  String get accountLoadSamples => 'नमुना ढुवानी लोड गर्नुहोस्';

  @override
  String get accountLoadSamplesTitle => 'नमुना ढुवानी लोड गर्ने?';

  @override
  String get accountLoadSamplesBody =>
      'तपाईंका ढुवानी र बिड नमुना सेट (LOD-1001 देखि LOD-1004) ले बदलिनेछन्, ताकि हरेक सुविधा हेर्न सकियोस्। नयाँ सन्दर्भ नम्बर अन्तिम प्रयोग भएकोबाट अगाडि बढ्छन्।';

  @override
  String get accountLoadSamplesConfirm => 'नमुना लोड गर्नुहोस्';

  @override
  String get accountSamplesLoaded => 'नमुना ढुवानी लोड भयो।';

  @override
  String get accountSignOutTitle => 'साइन आउट गर्ने?';

  @override
  String get accountSignOutDraft =>
      'तपाईंको अधुरो लोड अर्को पटकका लागि ड्राफ्टमा सुरक्षित रहनेछ।';

  @override
  String get accountSignOutBody =>
      'ढुवानी व्यवस्थापन गर्न फेरि लगइन गर्नुपर्नेछ।';

  @override
  String get individualShipper => 'व्यक्तिगत शिपर';

  @override
  String get profileNote =>
      'तपाईंले पोस्ट गरेका लोडमा ढुवानीकर्ताले तपाईंको नाम र कम्पनी देख्छन्।';

  @override
  String get profilePhoneHelper => 'यो नम्बरबाट लगइन गर्न सक्नुहुन्छ।';

  @override
  String get profileEmailHelper =>
      'तपाईंको साइन-इन इमेल। बदल्न सहयोगमा सम्पर्क गर्नुहोस्।';

  @override
  String get profileUpdated => 'प्रोफाइल अपडेट भयो';

  @override
  String get feedbackMin => 'अलि विस्तारमा लेख्नुहोस् (कम्तीमा १० अक्षर)।';

  @override
  String get feedbackSent => 'धन्यवाद! तपाईंको प्रतिक्रिया पठाइयो।';

  @override
  String get feedbackSubtitle => 'हामी हरेक सन्देश पढ्छौँ।';

  @override
  String get feedbackProblem => 'समस्या';

  @override
  String get feedbackIdea => 'सुझाव';

  @override
  String get feedbackQuestion => 'प्रश्न';

  @override
  String get feedbackProblemHint => 'के भयो, र के हुनुपर्थ्यो?';

  @override
  String get feedbackIdeaHint =>
      'LODBOD लाई तपाईंका लागि के ले अझ राम्रो बनाउँछ?';

  @override
  String get feedbackQuestionHint => 'के जान्न चाहनुहुन्छ?';

  @override
  String get feedbackSend => 'पठाउनुहोस्';

  @override
  String get helpFaq => 'बारम्बार सोधिने प्रश्न';

  @override
  String get helpQ1 => 'लोड कसरी पोस्ट गर्ने?';

  @override
  String get helpA1 =>
      'लोड पोस्ट थिच्नुहोस्, रुट र पिकअप समय लेख्नुहोस्, मालको विवरण दिनुहोस् र सवारी छान्नुहोस्। समीक्षा गरेर पोस्ट गर्नुहोस्। ढुवानीकर्ताले तुरुन्तै बिड गर्न सक्छन्।';

  @override
  String get helpQ2 => 'किन ३ वटा मात्र खुला अनुरोध राख्न सकिन्छ?';

  @override
  String helpA2(int max) {
    return 'मोबाइल एपबाट एकपटकमा बढीमा $max अनुरोध बिड पर्खँदै, पक्का, तालिका बनेका वा बाटोमा रहन सक्छन्। डेलिभर, रद्द वा म्याद सकिएका अनुरोधले ठाउँ खाली गर्छन्। थप मात्राका लागि LODBOD वेब प्लेटफर्म प्रयोग गर्नुहोस्।';
  }

  @override
  String get helpQ3 => 'बिड कसरी छान्ने?';

  @override
  String get helpA3 =>
      'आफ्नो ढुवानी खोलेर बिड तुलना थिच्नुहोस्। मूल्य, रेटिङ वा डेलिभरी समय अनुसार क्रमबद्ध गर्न र कुनै पनि प्रस्तावको विवरण हेर्न सक्नुहुन्छ। तपाईंले पुष्टि नगरेसम्म केही बुक हुँदैन।';

  @override
  String get helpQ4 => 'ढुवानी रद्द गर्न सकिन्छ?';

  @override
  String get helpA4 =>
      'सकिन्छ, पिकअपअघिसम्म। ढुवानी खोलेर ⋮ मेनुबाट ढुवानी रद्द गर्नुहोस् छान्नुहोस्। खुला बिड अस्वीकार हुन्छन्।';

  @override
  String get helpQ5 => 'मेरो ट्रक कहाँ छ?';

  @override
  String get helpA5 =>
      'बुक भएका ढुवानीमा रुट, चेकपोइन्ट र अनुमानित आगमन देखाउने ढुवानी ट्र्याक स्क्रिन छ। यस संस्करणमा ट्र्याकिङ तालिकाबाट नक्कल गरिएको छ।';

  @override
  String get helpQ6 => 'अधुरो लोड हराउँछ?';

  @override
  String get helpA6 =>
      'हराउँदैन। लोड पोस्ट बन्द गर्दा वा ड्राफ्ट सुरक्षित थिच्दा ड्राफ्ट तपाईंको खातामा सुरक्षित हुन्छ, पछि पूरा गर्न सक्नुहुन्छ।';

  @override
  String get helpStillNeed => 'अझै सहयोग चाहियो?';

  @override
  String get helpStillNeedBody =>
      'हामीलाई सन्देश पठाउनुहोस्, टोलीले सम्पर्क गर्नेछ।';

  @override
  String get helpMessage => 'सन्देश';

  @override
  String get legalSummaryUpdated => 'सारांश · ८ नोभेम्बर २०२६ मा अद्यावधिक';

  @override
  String get legalT1 => 'LODBOD को प्रयोग';

  @override
  String get legalT1Body =>
      'LODBOD ले शिपरलाई स्वतन्त्र ढुवानीकर्तासँग जोड्छ। आफ्ना लोड, रुट र सम्पर्कको सही विवरण दिनुपर्छ।';

  @override
  String get legalT2 => 'लोड पोस्ट गर्ने';

  @override
  String get legalT2Body =>
      'पोस्ट गरिएको लोड ढुवानीकर्तालाई बिड गर्ने निम्तो हो। मोबाइल खातामा एकपटकमा बढीमा ३ खुला अनुरोध राख्न सकिन्छ; थप अनुरोध LODBOD वेब प्लेटफर्ममा बनाउन सकिन्छ।';

  @override
  String get legalT3 => 'बिड र बुकिङ';

  @override
  String get legalT3Body =>
      'बिड स्वीकार गरेर पुष्टि गरेपछि मात्र बुकिङ हुन्छ। एउटा बिड स्वीकार गर्दा त्यो लोडका अन्य बिड अस्वीकार हुन्छन्।';

  @override
  String get legalT4 => 'रद्द';

  @override
  String get legalT4Body =>
      'पिकअपअघि अनुरोध रद्द गर्न सकिन्छ। बारम्बार ढिलो रद्द गर्दा तपाईंको पहुँचमा असर पर्न सक्छ।';

  @override
  String get legalT5 => 'भुक्तानी';

  @override
  String get legalT5Body =>
      'भाडा तपाईं र ढुवानीकर्ताबीच नेपाली रुपैयाँमा तय हुन्छ। बुकिङ पुष्टि गर्नुअघि भुक्तानी सर्त देखाइन्छ।';

  @override
  String get legalP1 => 'हामी के सङ्कलन गर्छौँ';

  @override
  String get legalP1Body =>
      'तपाईंको नाम, फोन नम्बर, इमेल, कम्पनी, र तपाईंले पोस्ट गरेका लोड, पाएका बिड र गरेका बुकिङका विवरण।';

  @override
  String get legalP2 => 'कसरी प्रयोग गर्छौँ';

  @override
  String get legalP2Body =>
      'तपाईंको खाता चलाउन, लोड ढुवानीकर्तालाई देखाउन, बुकिङ प्रशोधन गर्न, सेवा सन्देश पठाउन र LODBOD सुधार्न।';

  @override
  String get legalP3 => 'ढुवानीकर्ताले के देख्छन्';

  @override
  String get legalP3Body =>
      'ढुवानीकर्ताले तपाईंको कम्पनीको नाम, रुट, माल र तालिका देख्छन्। फोन नम्बर तपाईंले बुक गरेको ढुवानीकर्तासँग मात्र साझा हुन्छ।';

  @override
  String get legalP4 => 'तपाईंका विकल्प';

  @override
  String get legalP4Body =>
      'तपाईं जहिले पनि प्रोफाइल अपडेट गर्न र खाताबाट एपभित्रका सूचना नियन्त्रण गर्न सक्नुहुन्छ।';

  @override
  String get legalP5 => 'सुरक्षा';

  @override
  String get legalP5Body =>
      'तपाईंको डेटा ओसारपसार र भण्डारण दुवैमा उद्योग-मानक इन्क्रिप्सनसहित राखिन्छ।';

  @override
  String get trackEstimatedUnavailable =>
      'तालिकाबाट अनुमानित · लाइभ अपडेट उपलब्ध छैन';

  @override
  String get trackSimulatedSample => 'नक्कली ट्र्याकिङ · नमुना रुट';

  @override
  String get trackJustNow => 'भर्खरै';

  @override
  String trackSecondsAgo(int s) {
    return '$s से. अघि';
  }

  @override
  String trackLiveLine(String age) {
    return 'लाइभ · नक्कली चालक · $age';
  }

  @override
  String get trackStopped => ' · रोकिएको';

  @override
  String trackSpeed(int kmh) {
    return ' · $kmh कि.मी./घण्टा';
  }

  @override
  String trackAtDestination(String place) {
    return '$place मा · ढुवानीकर्ताको डेलिभरी पुष्टि पर्खँदै';
  }

  @override
  String trackExpectedLate(String when, int km) {
    return 'अपेक्षित $when · $km कि.मी. बाँकी';
  }

  @override
  String trackRemaining(String prefix, int km, String speed) {
    return '$prefix$km कि.मी. बाँकी$speed';
  }

  @override
  String get trackAwaitingPickup => 'पिकअप पर्खँदै';

  @override
  String trackPickupTrip(String when, int km) {
    return 'पिकअप $when · $km कि.मी. यात्रा';
  }

  @override
  String trackProgress(String place, int pct) {
    return '$place · $pct%';
  }

  @override
  String get trackRoute => 'रुट';

  @override
  String trackPickupLine(String when) {
    return 'पिकअप · $when';
  }

  @override
  String trackEstimated(String when) {
    return 'अनुमानित $when';
  }

  @override
  String get trackPassed => 'पार भयो';

  @override
  String get trackUpcoming => 'आउँदै';

  @override
  String trackFastForward(int factor) {
    return 'नक्कल: फास्ट-फर्वार्ड ×$factor';
  }

  @override
  String get trackEnRoute => 'बाटोमा';
}
