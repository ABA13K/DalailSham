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
  String get locationLoading => 'Finding places near you…';

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
  String get detailsTitle => 'Place details';

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
  String get localeSwitchTooltip => 'Switch language';

  @override
  String get storiesTitle => 'Stories';
}
