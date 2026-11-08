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

  /// No description provided for @sectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact & location'**
  String get sectionContact;

  /// No description provided for @labelReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get labelReviews;

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
  /// **'Type to narrow the services below by name, category or area, then press search to look through the whole directory.'**
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

  /// No description provided for @chatLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Messages stay on this device only — chat is not connected yet.'**
  String get chatLocalNotice;

  /// No description provided for @servicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services here yet'**
  String get servicesEmpty;

  /// No description provided for @servicesError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading services'**
  String get servicesError;

  /// No description provided for @topRatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Top rated services'**
  String get topRatedTitle;

  /// No description provided for @nearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearest to you'**
  String get nearbyTitle;

  /// No description provided for @nearbyRandomTitle.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get nearbyRandomTitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet — tap the heart on a service to keep it here.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesNeedLogin.
  ///
  /// In en, this message translates to:
  /// **'Favorites need an account. Sign in and try again.'**
  String get favoritesNeedLogin;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @favoritesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update favorites'**
  String get favoritesError;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @loginFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or mobile'**
  String get loginFieldLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @mobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

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

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your gender'**
  String get genderRequired;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get loggedIn;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @accountProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfileTitle;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileSaved;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get that photo'**
  String get photoPickFailed;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This removes your account for good. Enter your password to confirm.'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @vendorServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'My service'**
  String get vendorServiceTitle;

  /// No description provided for @vendorServiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get vendorServiceSaved;

  /// No description provided for @removeMainImage.
  ///
  /// In en, this message translates to:
  /// **'Remove cover photo'**
  String get removeMainImage;

  /// No description provided for @nameArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get nameArabicLabel;

  /// No description provided for @nameEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get nameEnglishLabel;

  /// No description provided for @addressArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (Arabic)'**
  String get addressArabicLabel;

  /// No description provided for @addressEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (English)'**
  String get addressEnglishLabel;

  /// No description provided for @descriptionArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get descriptionArabicLabel;

  /// No description provided for @descriptionEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get descriptionEnglishLabel;

  /// No description provided for @mapsUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Google Maps link'**
  String get mapsUrlLabel;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a link starting with http or https'**
  String get invalidUrl;

  /// No description provided for @invalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get invalidLatitude;

  /// No description provided for @invalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get invalidLongitude;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'This text is too long'**
  String get tooLong;

  /// No description provided for @labelRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get labelRating;

  /// No description provided for @labelVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get labelVisits;

  /// No description provided for @labelPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get labelPlan;

  /// No description provided for @labelFlag.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get labelFlag;

  /// No description provided for @mainServiceFlag.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainServiceFlag;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that search'**
  String get searchEmpty;

  /// No description provided for @vendorJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'List your service'**
  String get vendorJoinTitle;

  /// No description provided for @joinIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself and your service. The listing goes live after an admin reviews it.'**
  String get joinIntro;

  /// No description provided for @joinAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get joinAccountSection;

  /// No description provided for @joinServiceSection.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get joinServiceSection;

  /// No description provided for @labelRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get labelRegion;

  /// No description provided for @chooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose a region'**
  String get chooseRegion;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @regionRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the region your service is in'**
  String get regionRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the category that fits your service'**
  String get categoryRequired;

  /// No description provided for @companyEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Company email (optional)'**
  String get companyEmailLabel;

  /// No description provided for @addCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add cover photo'**
  String get addCoverPhoto;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @joinRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request sent — an admin will review it'**
  String get joinRequestSubmitted;

  /// No description provided for @vendorContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact lines'**
  String get vendorContactsTitle;

  /// No description provided for @contactsIntro.
  ///
  /// In en, this message translates to:
  /// **'The numbers, emails and links customers reach your service through.'**
  String get contactsIntro;

  /// No description provided for @contactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get contactsEmpty;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add a contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// No description provided for @chooseContactType.
  ///
  /// In en, this message translates to:
  /// **'Choose a type'**
  String get chooseContactType;

  /// No description provided for @labelContactType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labelContactType;

  /// No description provided for @labelContactValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get labelContactValue;

  /// No description provided for @contactTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the kind of contact'**
  String get contactTypeRequired;

  /// No description provided for @contactValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the number, address or link'**
  String get contactValueRequired;

  /// No description provided for @saveContact.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveContact;

  /// No description provided for @contactSaved.
  ///
  /// In en, this message translates to:
  /// **'Contact saved'**
  String get contactSaved;

  /// No description provided for @primaryContact.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primaryContact;

  /// No description provided for @setPrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'Make primary'**
  String get setPrimaryContact;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteContact;

  /// No description provided for @deleteContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this contact?'**
  String get deleteContactQuestion;

  /// No description provided for @vendorImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service photos'**
  String get vendorImagesTitle;

  /// No description provided for @imagesIntro.
  ///
  /// In en, this message translates to:
  /// **'The pictures shown under your service, once an admin approves them.'**
  String get imagesIntro;

  /// Photos a vendor has published against the limit they may hold
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}'**
  String imagesLimit(int count, int max);

  /// No description provided for @imagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get imagesEmpty;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addImage;

  /// No description provided for @imagePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get imagePendingApproval;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deleteImage;

  /// No description provided for @deleteImageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get deleteImageQuestion;

  /// No description provided for @deleteAllImages.
  ///
  /// In en, this message translates to:
  /// **'Delete all photos'**
  String get deleteAllImages;

  /// No description provided for @deleteAllImagesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete every photo of this service?'**
  String get deleteAllImagesQuestion;

  /// How many photos the delete-all endpoint answered it removed
  ///
  /// In en, this message translates to:
  /// **'Removed {count} photos'**
  String imagesRemovedAll(int count);

  /// No description provided for @imagesLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No room for another photo'**
  String get imagesLimitReached;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type to search the listed services'**
  String get searchPrompt;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get filterRegion;

  /// No description provided for @filterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get filterSort;

  /// No description provided for @filterRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get filterRating;

  /// No description provided for @sortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get sortLatest;

  /// No description provided for @sortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortTopRated;

  /// No description provided for @sortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortNearest;

  /// No description provided for @ratingAny.
  ///
  /// In en, this message translates to:
  /// **'Any rating'**
  String get ratingAny;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @vendorProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get vendorProductsTitle;

  /// No description provided for @productsIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything your service sells. A new or edited product waits for an admin before customers see it.'**
  String get productsIntro;

  /// No description provided for @productsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get productsSearchHint;

  /// No description provided for @productsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmpty;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// No description provided for @deleteProductQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this product?'**
  String get deleteProductQuestion;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @productPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get productPendingApproval;

  /// No description provided for @productHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get productHidden;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get productUnavailable;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (SYP)'**
  String get priceLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shown to customers'**
  String get activeLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get availableLabel;

  /// No description provided for @productCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the category this product belongs to'**
  String get productCategoryRequired;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @statusAny.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get statusAny;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a price from 0 to 9999999.99'**
  String get invalidPrice;

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number up to 999999'**
  String get invalidQuantity;

  /// No description provided for @vendorAmenitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service amenities'**
  String get vendorAmenitiesTitle;

  /// No description provided for @amenitiesIntro.
  ///
  /// In en, this message translates to:
  /// **'What your service offers besides what it sells. A new or edited amenity waits for an admin before customers see it.'**
  String get amenitiesIntro;

  /// Amenities a vendor has published against the limit they may hold
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}'**
  String amenitiesLimit(int count, int max);

  /// No description provided for @amenitiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No amenities yet'**
  String get amenitiesEmpty;

  /// No description provided for @addAmenity.
  ///
  /// In en, this message translates to:
  /// **'Add amenity'**
  String get addAmenity;

  /// No description provided for @editAmenity.
  ///
  /// In en, this message translates to:
  /// **'Edit amenity'**
  String get editAmenity;

  /// No description provided for @deleteAmenity.
  ///
  /// In en, this message translates to:
  /// **'Delete amenity'**
  String get deleteAmenity;

  /// No description provided for @deleteAmenityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this amenity?'**
  String get deleteAmenityQuestion;

  /// No description provided for @deleteAllAmenities.
  ///
  /// In en, this message translates to:
  /// **'Delete all amenities'**
  String get deleteAllAmenities;

  /// No description provided for @deleteAllAmenitiesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete every amenity of this service?'**
  String get deleteAllAmenitiesQuestion;

  /// How many amenities the delete-all endpoint answered it removed
  ///
  /// In en, this message translates to:
  /// **'Removed {count} amenities'**
  String amenitiesRemovedAll(int count);

  /// No description provided for @amenitiesLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No room for another amenity'**
  String get amenitiesLimitReached;

  /// No description provided for @amenityPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get amenityPendingApproval;

  /// No description provided for @amenityWaitsForApproval.
  ///
  /// In en, this message translates to:
  /// **'The amenity reaches customers once an admin approves it.'**
  String get amenityWaitsForApproval;

  /// No description provided for @amenitySaved.
  ///
  /// In en, this message translates to:
  /// **'Amenity saved'**
  String get amenitySaved;

  /// No description provided for @amenityDeleted.
  ///
  /// In en, this message translates to:
  /// **'Amenity deleted'**
  String get amenityDeleted;

  /// No description provided for @vendorStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a story'**
  String get vendorStoriesTitle;

  /// No description provided for @storyTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Story type'**
  String get storyTypeTitle;

  /// No description provided for @storyTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get storyTypeImage;

  /// No description provided for @storyTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get storyTypeVideo;

  /// No description provided for @storyTypePoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get storyTypePoll;

  /// No description provided for @storyCaptionArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (Arabic)'**
  String get storyCaptionArabicLabel;

  /// No description provided for @storyCaptionEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (English)'**
  String get storyCaptionEnglishLabel;

  /// No description provided for @storyPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get storyPickPhoto;

  /// No description provided for @storyPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose a video'**
  String get storyPickVideo;

  /// No description provided for @storyPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the photo this story shows'**
  String get storyPhotoRequired;

  /// No description provided for @storyVideoRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the video this story shows'**
  String get storyVideoRequired;

  /// No description provided for @storyQuestionArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Question (Arabic)'**
  String get storyQuestionArabicLabel;

  /// No description provided for @storyQuestionEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'Question (English)'**
  String get storyQuestionEnglishLabel;

  /// No description provided for @storyOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Poll options'**
  String get storyOptionsLabel;

  /// Label of one poll option field, counted from the first row
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String storyOptionLabel(int number);

  /// No description provided for @storyAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get storyAddOption;

  /// No description provided for @storyRemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Remove this option'**
  String get storyRemoveOption;

  /// No description provided for @storyOptionsTooFew.
  ///
  /// In en, this message translates to:
  /// **'A poll needs at least two options'**
  String get storyOptionsTooFew;

  /// No description provided for @storyPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish story'**
  String get storyPublish;

  /// No description provided for @storySaved.
  ///
  /// In en, this message translates to:
  /// **'Story created, waiting for approval'**
  String get storySaved;

  /// No description provided for @storyWaitsForApproval.
  ///
  /// In en, this message translates to:
  /// **'The story reaches customers once an admin approves it.'**
  String get storyWaitsForApproval;

  /// Hours a published story has left before it drops off the feed
  ///
  /// In en, this message translates to:
  /// **'Gone in {hours} h'**
  String storyExpiresIn(int hours);

  /// No description provided for @storyNoVotes.
  ///
  /// In en, this message translates to:
  /// **'No votes yet'**
  String get storyNoVotes;

  /// No description provided for @storyVoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an answer to vote'**
  String get storyVoteHint;

  /// No description provided for @storyVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Your vote could not be recorded'**
  String get storyVoteFailed;

  /// No description provided for @serviceStoriesAll.
  ///
  /// In en, this message translates to:
  /// **'See all stories from this service'**
  String get serviceStoriesAll;

  /// No description provided for @serviceStoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'This service has no stories right now'**
  String get serviceStoriesEmpty;

  /// No description provided for @cityTitle.
  ///
  /// In en, this message translates to:
  /// **'Damascus'**
  String get cityTitle;

  /// No description provided for @mainCategories.
  ///
  /// In en, this message translates to:
  /// **'Main categories'**
  String get mainCategories;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing new right now'**
  String get notificationsEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @serviceProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Service profile'**
  String get serviceProfileTitle;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sectionPhotos;

  /// How many pictures a service published
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String photosCount(int count);

  /// Which picture of the set the viewer is showing
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String galleryPosition(int current, int total);

  /// No description provided for @galleryError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading photos'**
  String get galleryError;

  /// No description provided for @sectionMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get sectionMenu;

  /// No description provided for @menuError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading products'**
  String get menuError;

  /// How many products a menu or one of its categories holds
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String productsCount(int count);

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @sectionReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reviews'**
  String get sectionReviews;

  /// No description provided for @reviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmpty;

  /// No description provided for @reviewsError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading reviews'**
  String get reviewsError;

  /// How many opinions a service collected
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @sortHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get sortHighest;

  /// No description provided for @sortLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest rated'**
  String get sortLowest;

  /// No description provided for @reviewMine.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get reviewMine;

  /// No description provided for @reviewAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get reviewAnonymous;

  /// No description provided for @sectionHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get sectionHours;

  /// No description provided for @hoursToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get hoursToday;

  /// No description provided for @sectionAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get sectionAmenities;

  /// How many times readers opened this service
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 visit} other{{count} visits}}'**
  String visitsCount(int count);
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
