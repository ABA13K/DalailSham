// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dali Alsham';

  @override
  String get appTagline => 'Discover places around you';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start exploring';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Dali Alsham';

  @override
  String get onboardingWelcomeBody =>
      'Your guide to the best restaurants, cafés and landmarks around you.';

  @override
  String get onboardingExploreTitle => 'Everything nearby';

  @override
  String get onboardingExploreBody =>
      'Restaurants, cafés, hotels, landmarks, pharmacies and banks — filter, search and find what suits you.';

  @override
  String get onboardingLocationTitle => 'Places on the map';

  @override
  String get onboardingLocationBody =>
      'Allow location access to see the closest places and get directions with one tap.';

  @override
  String get homeTitle => 'Nearby places';

  @override
  String get searchHint => 'Search places…';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryRestaurant => 'Restaurants';

  @override
  String get categoryCafe => 'Cafés';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryHotel => 'Hotels';

  @override
  String get categoryAttraction => 'Attractions';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryBank => 'Banks';

  @override
  String get exploreCategories => 'Explore categories';

  @override
  String get seeAll => 'See all';

  @override
  String get loadMore => 'Load more';

  @override
  String get categoriesEmpty => 'No categories yet';

  @override
  String get exploreRegions => 'Explore regions';

  @override
  String get regionsEmpty => 'No regions yet';

  @override
  String servicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '$count service',
    );
    return '$_temp0';
  }

  @override
  String get locationPermissionTitle => 'Location needed';

  @override
  String get locationPermissionMessage =>
      'We use your location to find places around you. Please enable it in system settings.';

  @override
  String get locationServiceDisabled =>
      'Location services are turned off. Please enable them in system settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get placesEmpty => 'No places found nearby';

  @override
  String get placesError => 'Something went wrong while loading places';

  @override
  String get retry => 'Retry';

  @override
  String distanceMeters(int value) {
    return '$value m';
  }

  @override
  String distanceKilometers(num value) {
    return '$value km';
  }

  @override
  String get profileTitle => 'Business profile';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionContact => 'Contact & location';

  @override
  String get sectionAmenities => 'Services & amenities';

  @override
  String get sectionReviews => 'Ratings & reviews';

  @override
  String get labelPrice => 'Price';

  @override
  String get labelReviews => 'Reviews';

  @override
  String get labelSince => 'Since';

  @override
  String get statusOpenNow => 'Open now';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusOpen24 => 'Open 24 hours';

  @override
  String get directions => 'Directions';

  @override
  String get viewStory => 'Watch story';

  @override
  String get viewPhoto => 'Show photo';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String profilePopularFor(String first, String second) {
    return 'Locals come here for $first and $second.';
  }

  @override
  String get labelCategory => 'Category';

  @override
  String get labelDistance => 'Distance';

  @override
  String get labelAddress => 'Address';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelWebsite => 'Website';

  @override
  String get labelOpeningHours => 'Opening hours';

  @override
  String get valueUnknown => 'Not available';

  @override
  String get getDirections => 'Get directions';

  @override
  String get call => 'Call';

  @override
  String get visitWebsite => 'Visit website';

  @override
  String get unsupportedAction => 'This action is not available on this device';

  @override
  String get changeLanguage => 'العربية';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get adLabel => 'Ad';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuSubtitle => 'Sample menu · prices in Syrian pounds';

  @override
  String get currencySyp => 'SYP';

  @override
  String ratingSummary(String rating, int count) {
    return 'Rated $rating out of 5 · $count reviews';
  }

  @override
  String get tutorialMenu => 'App tutorial';

  @override
  String get tutorialStoriesTitle => 'Stories';

  @override
  String get tutorialStoriesBody =>
      'Tap any circle at the top to preview places full-screen. Watched stories turn grey.';

  @override
  String get tutorialAdsTitle => 'Offers';

  @override
  String get tutorialAdsBody =>
      'Local offers scroll automatically — swipe to browse them yourself.';

  @override
  String get tutorialSearchTitle => 'Search & filters';

  @override
  String get tutorialSearchBody =>
      'Search by name, then narrow the results with the category chips below.';

  @override
  String get tutorialMenuTitle => 'Menu & settings';

  @override
  String get tutorialMenuBody =>
      'Open the menu to switch language, enable dark mode, or replay this tour.';

  @override
  String get tutorialDone => 'Got it';

  @override
  String get storiesTitle => 'Stories';

  @override
  String get storiesNow => 'Now';

  @override
  String get storiesClose => 'Close stories';

  @override
  String get viewPlace => 'View place';

  @override
  String get demoDataNotice => 'Demo data — live places are unavailable.';

  @override
  String get chat => 'Chat';

  @override
  String get chatRoomTitle => 'Chat room';

  @override
  String get chatHint => 'Write a message…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatEmpty => 'No messages yet — start the conversation.';

  @override
  String get chatError => 'Something went wrong while loading messages';

  @override
  String get chatDemoNotice => 'Demo chat — messages stay on this device only.';

  @override
  String get servicesEmpty => 'No services in this category yet';
}
