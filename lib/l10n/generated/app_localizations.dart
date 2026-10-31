import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dali Alsham'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover places around you'**
  String get appTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dali Alsham'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your guide to the best restaurants, cafés and landmarks around you.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything nearby'**
  String get onboardingExploreTitle;

  /// No description provided for @onboardingExploreBody.
  ///
  /// In en, this message translates to:
  /// **'Restaurants, cafés, hotels, landmarks, pharmacies and banks — filter, search and find what suits you.'**
  String get onboardingExploreBody;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Places on the map'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see the closest places and get directions with one tap.'**
  String get onboardingLocationBody;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby places'**
  String get homeTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places…'**
  String get searchHint;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurant;

  /// No description provided for @categoryCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafés'**
  String get categoryCafe;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get categoryHotel;

  /// No description provided for @categoryAttraction.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get categoryAttraction;

  /// No description provided for @categoryFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get categoryFuel;

  /// No description provided for @categoryBank.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get categoryBank;

  /// No description provided for @exploreCategories.
  ///
  /// In en, this message translates to:
  /// **'Explore categories'**
  String get exploreCategories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmpty;

  /// No description provided for @exploreRegions.
  ///
  /// In en, this message translates to:
  /// **'Explore regions'**
  String get exploreRegions;

  /// No description provided for @regionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No regions yet'**
  String get regionsEmpty;

  /// Number of services published in a region
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} service} other{{count} services}}'**
  String servicesCount(int count);

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location needed'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We use your location to find places around you. Please enable it in system settings.'**
  String get locationPermissionMessage;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please enable them in system settings.'**
  String get locationServiceDisabled;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @placesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places found nearby'**
  String get placesEmpty;

  /// No description provided for @placesError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading places'**
  String get placesError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Distance in meters
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String distanceMeters(int value);

  /// Distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKilometers(num value);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get profileTitle;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact & location'**
  String get sectionContact;

  /// No description provided for @sectionAmenities.
  ///
  /// In en, this message translates to:
  /// **'Services & amenities'**
  String get sectionAmenities;

  /// No description provided for @sectionReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reviews'**
  String get sectionReviews;

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @labelReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get labelReviews;

  /// No description provided for @labelSince.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get labelSince;

  /// No description provided for @statusOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get statusOpenNow;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusOpen24.
  ///
  /// In en, this message translates to:
  /// **'Open 24 hours'**
  String get statusOpen24;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @viewStory.
  ///
  /// In en, this message translates to:
  /// **'Watch story'**
  String get viewStory;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Show photo'**
  String get viewPhoto;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @profilePopularFor.
  ///
  /// In en, this message translates to:
  /// **'Locals come here for {first} and {second}.'**
  String profilePopularFor(String first, String second);

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get labelDistance;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// No description provided for @labelWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get labelWebsite;

  /// No description provided for @labelOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get labelOpeningHours;

  /// No description provided for @valueUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get valueUnknown;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get getDirections;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit website'**
  String get visitWebsite;

  /// No description provided for @unsupportedAction.
  ///
  /// In en, this message translates to:
  /// **'This action is not available on this device'**
  String get unsupportedAction;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get changeLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @adLabel.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get adLabel;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @menuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sample menu · prices in Syrian pounds'**
  String get menuSubtitle;

  /// No description provided for @currencySyp.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currencySyp;

  /// No description provided for @ratingSummary.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5 · {count} reviews'**
  String ratingSummary(String rating, int count);

  /// No description provided for @tutorialMenu.
  ///
  /// In en, this message translates to:
  /// **'App tutorial'**
  String get tutorialMenu;

  /// No description provided for @tutorialStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get tutorialStoriesTitle;

  /// No description provided for @tutorialStoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any circle at the top to preview places full-screen. Watched stories turn grey.'**
  String get tutorialStoriesBody;

  /// No description provided for @tutorialAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get tutorialAdsTitle;

  /// No description provided for @tutorialAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Local offers scroll automatically — swipe to browse them yourself.'**
  String get tutorialAdsBody;

  /// No description provided for @tutorialSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & filters'**
  String get tutorialSearchTitle;

  /// No description provided for @tutorialSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search by name, then narrow the results with the category chips below.'**
  String get tutorialSearchBody;

  /// No description provided for @tutorialMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu & settings'**
  String get tutorialMenuTitle;

  /// No description provided for @tutorialMenuBody.
  ///
  /// In en, this message translates to:
  /// **'Open the menu to switch language, enable dark mode, or replay this tour.'**
  String get tutorialMenuBody;

  /// No description provided for @tutorialDone.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tutorialDone;

  /// No description provided for @storiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storiesTitle;

  /// No description provided for @storiesNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get storiesNow;

  /// No description provided for @storiesClose.
  ///
  /// In en, this message translates to:
  /// **'Close stories'**
  String get storiesClose;

  /// No description provided for @viewPlace.
  ///
  /// In en, this message translates to:
  /// **'View place'**
  String get viewPlace;

  /// No description provided for @demoDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo data — live places are unavailable.'**
  String get demoDataNotice;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat room'**
  String get chatRoomTitle;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet — start the conversation.'**
  String get chatEmpty;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading messages'**
  String get chatError;

  /// No description provided for @chatDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo chat — messages stay on this device only.'**
  String get chatDemoNotice;

  /// No description provided for @servicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services in this category yet'**
  String get servicesEmpty;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
