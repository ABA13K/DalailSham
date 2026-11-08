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
  String get sectionContact => 'Contact & location';

  @override
  String get labelReviews => 'Reviews';

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
      'Type to narrow the services below by name, category or area, then press search to look through the whole directory.';

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
  String get chatLocalNotice =>
      'Messages stay on this device only — chat is not connected yet.';

  @override
  String get servicesEmpty => 'No services here yet';

  @override
  String get servicesError => 'Something went wrong while loading services';

  @override
  String get topRatedTitle => 'Top rated services';

  @override
  String get nearbyTitle => 'Nearest to you';

  @override
  String get nearbyRandomTitle => 'Picked for you';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty =>
      'No favorites yet — tap the heart on a service to keep it here.';

  @override
  String get favoritesNeedLogin =>
      'Favorites need an account. Sign in and try again.';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get favoritesError => 'Couldn\'t update favorites';

  @override
  String get accountTitle => 'Account';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Create account';

  @override
  String get loginFieldLabel => 'Email or mobile';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get mobileLabel => 'Mobile number';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get addressLabel => 'Address (optional)';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get signIn => 'Sign in';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get fieldRequired => 'Required';

  @override
  String get passwordTooShort => 'Use at least 6 characters';

  @override
  String get passwordMismatch => 'The two passwords do not match';

  @override
  String get genderRequired => 'Choose your gender';

  @override
  String get loggedIn => 'Signed in successfully';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get signedOut => 'Signed out';

  @override
  String get logout => 'Logout';

  @override
  String get accountProfileTitle => 'Profile';

  @override
  String get profileSaved => 'Profile updated successfully';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoPickFailed => 'Couldn\'t get that photo';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarning =>
      'This removes your account for good. Enter your password to confirm.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get cancel => 'Cancel';

  @override
  String get vendorServiceTitle => 'My service';

  @override
  String get vendorServiceSaved => 'Service updated successfully';

  @override
  String get removeMainImage => 'Remove cover photo';

  @override
  String get nameArabicLabel => 'Name (Arabic)';

  @override
  String get nameEnglishLabel => 'Name (English)';

  @override
  String get addressArabicLabel => 'Address (Arabic)';

  @override
  String get addressEnglishLabel => 'Address (English)';

  @override
  String get descriptionArabicLabel => 'Description (Arabic)';

  @override
  String get descriptionEnglishLabel => 'Description (English)';

  @override
  String get mapsUrlLabel => 'Google Maps link';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get invalidUrl => 'Enter a link starting with http or https';

  @override
  String get invalidLatitude => 'Latitude must be between -90 and 90';

  @override
  String get invalidLongitude => 'Longitude must be between -180 and 180';

  @override
  String get tooLong => 'This text is too long';

  @override
  String get labelRating => 'Rating';

  @override
  String get labelVisits => 'Visits';

  @override
  String get labelPlan => 'Plan';

  @override
  String get labelFlag => 'Service';

  @override
  String get mainServiceFlag => 'Main';

  @override
  String get searchEmpty => 'Nothing matched that search';

  @override
  String get vendorJoinTitle => 'List your service';

  @override
  String get joinIntro =>
      'Tell us about yourself and your service. The listing goes live after an admin reviews it.';

  @override
  String get joinAccountSection => 'Account';

  @override
  String get joinServiceSection => 'Service';

  @override
  String get labelRegion => 'Region';

  @override
  String get chooseRegion => 'Choose a region';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get regionRequired => 'Choose the region your service is in';

  @override
  String get categoryRequired => 'Choose the category that fits your service';

  @override
  String get companyEmailLabel => 'Company email (optional)';

  @override
  String get addCoverPhoto => 'Add cover photo';

  @override
  String get sendRequest => 'Send request';

  @override
  String get joinRequestSubmitted => 'Request sent — an admin will review it';

  @override
  String get vendorContactsTitle => 'Contact lines';

  @override
  String get contactsIntro =>
      'The numbers, emails and links customers reach your service through.';

  @override
  String get contactsEmpty => 'No contacts yet';

  @override
  String get addContact => 'Add a contact';

  @override
  String get editContact => 'Edit contact';

  @override
  String get chooseContactType => 'Choose a type';

  @override
  String get labelContactType => 'Type';

  @override
  String get labelContactValue => 'Value';

  @override
  String get contactTypeRequired => 'Choose the kind of contact';

  @override
  String get contactValueRequired => 'Enter the number, address or link';

  @override
  String get saveContact => 'Save';

  @override
  String get contactSaved => 'Contact saved';

  @override
  String get primaryContact => 'Primary';

  @override
  String get setPrimaryContact => 'Make primary';

  @override
  String get deleteContact => 'Delete';

  @override
  String get deleteContactQuestion => 'Delete this contact?';

  @override
  String get vendorImagesTitle => 'Service photos';

  @override
  String get imagesIntro =>
      'The pictures shown under your service, once an admin approves them.';

  @override
  String imagesLimit(int count, int max) {
    return '$count of $max';
  }

  @override
  String get imagesEmpty => 'No photos yet';

  @override
  String get addImage => 'Add a photo';

  @override
  String get imagePendingApproval => 'Waiting for approval';

  @override
  String get deleteImage => 'Delete photo';

  @override
  String get deleteImageQuestion => 'Delete this photo?';

  @override
  String get deleteAllImages => 'Delete all photos';

  @override
  String get deleteAllImagesQuestion => 'Delete every photo of this service?';

  @override
  String imagesRemovedAll(int count) {
    return 'Removed $count photos';
  }

  @override
  String get imagesLimitReached => 'No room for another photo';

  @override
  String get searchPrompt => 'Type to search the listed services';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterRegion => 'Region';

  @override
  String get filterSort => 'Sort';

  @override
  String get filterRating => 'Rating';

  @override
  String get sortLatest => 'Latest';

  @override
  String get sortTopRated => 'Top rated';

  @override
  String get sortNearest => 'Nearest';

  @override
  String get ratingAny => 'Any rating';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get vendorProductsTitle => 'Products';

  @override
  String get productsIntro =>
      'Everything your service sells. A new or edited product waits for an admin before customers see it.';

  @override
  String get productsSearchHint => 'Search products…';

  @override
  String get productsEmpty => 'No products yet';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get deleteProductQuestion => 'Delete this product?';

  @override
  String get productSaved => 'Product saved';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get productPendingApproval => 'Waiting for approval';

  @override
  String get productHidden => 'Hidden';

  @override
  String get productUnavailable => 'Not available';

  @override
  String get priceLabel => 'Price (SYP)';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get activeLabel => 'Shown to customers';

  @override
  String get availableLabel => 'In stock';

  @override
  String get productCategoryRequired =>
      'Choose the category this product belongs to';

  @override
  String get filterStatus => 'Status';

  @override
  String get statusAny => 'Any status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get invalidPrice => 'Enter a price from 0 to 9999999.99';

  @override
  String get invalidQuantity => 'Enter a whole number up to 999999';

  @override
  String get vendorAmenitiesTitle => 'Service amenities';

  @override
  String get amenitiesIntro =>
      'What your service offers besides what it sells. A new or edited amenity waits for an admin before customers see it.';

  @override
  String amenitiesLimit(int count, int max) {
    return '$count of $max';
  }

  @override
  String get amenitiesEmpty => 'No amenities yet';

  @override
  String get addAmenity => 'Add amenity';

  @override
  String get editAmenity => 'Edit amenity';

  @override
  String get deleteAmenity => 'Delete amenity';

  @override
  String get deleteAmenityQuestion => 'Delete this amenity?';

  @override
  String get deleteAllAmenities => 'Delete all amenities';

  @override
  String get deleteAllAmenitiesQuestion =>
      'Delete every amenity of this service?';

  @override
  String amenitiesRemovedAll(int count) {
    return 'Removed $count amenities';
  }

  @override
  String get amenitiesLimitReached => 'No room for another amenity';

  @override
  String get amenityPendingApproval => 'Waiting for approval';

  @override
  String get amenityWaitsForApproval =>
      'The amenity reaches customers once an admin approves it.';

  @override
  String get amenitySaved => 'Amenity saved';

  @override
  String get amenityDeleted => 'Amenity deleted';

  @override
  String get vendorStoriesTitle => 'Add a story';

  @override
  String get storyTypeTitle => 'Story type';

  @override
  String get storyTypeImage => 'Photo';

  @override
  String get storyTypeVideo => 'Video';

  @override
  String get storyTypePoll => 'Poll';

  @override
  String get storyCaptionArabicLabel => 'Caption (Arabic)';

  @override
  String get storyCaptionEnglishLabel => 'Caption (English)';

  @override
  String get storyPickPhoto => 'Choose a photo';

  @override
  String get storyPickVideo => 'Choose a video';

  @override
  String get storyPhotoRequired => 'Choose the photo this story shows';

  @override
  String get storyVideoRequired => 'Choose the video this story shows';

  @override
  String get storyQuestionArabicLabel => 'Question (Arabic)';

  @override
  String get storyQuestionEnglishLabel => 'Question (English)';

  @override
  String get storyOptionsLabel => 'Poll options';

  @override
  String storyOptionLabel(int number) {
    return 'Option $number';
  }

  @override
  String get storyAddOption => 'Add option';

  @override
  String get storyRemoveOption => 'Remove this option';

  @override
  String get storyOptionsTooFew => 'A poll needs at least two options';

  @override
  String get storyPublish => 'Publish story';

  @override
  String get storySaved => 'Story created, waiting for approval';

  @override
  String get storyWaitsForApproval =>
      'The story reaches customers once an admin approves it.';

  @override
  String storyExpiresIn(int hours) {
    return 'Gone in $hours h';
  }

  @override
  String get storyNoVotes => 'No votes yet';

  @override
  String get storyVoteHint => 'Tap an answer to vote';

  @override
  String get storyVoteFailed => 'Your vote could not be recorded';

  @override
  String get serviceStoriesAll => 'See all stories from this service';

  @override
  String get serviceStoriesEmpty => 'This service has no stories right now';

  @override
  String get cityTitle => 'Damascus';

  @override
  String get mainCategories => 'Main categories';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get notificationsEmpty => 'Nothing new right now';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navMenu => 'Menu';

  @override
  String get serviceProfileTitle => 'Service profile';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionPhotos => 'Photos';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String galleryPosition(int current, int total) {
    return '$current of $total';
  }

  @override
  String get galleryError => 'Something went wrong while loading photos';

  @override
  String get sectionMenu => 'Menu';

  @override
  String get menuError => 'Something went wrong while loading products';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get sectionReviews => 'Ratings & reviews';

  @override
  String get reviewsEmpty => 'No reviews yet';

  @override
  String get reviewsError => 'Something went wrong while loading reviews';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get sortHighest => 'Highest rated';

  @override
  String get sortLowest => 'Lowest rated';

  @override
  String get reviewMine => 'Your review';

  @override
  String get reviewAnonymous => 'Guest';

  @override
  String get sectionHours => 'Working hours';

  @override
  String get hoursToday => 'Today';

  @override
  String get sectionAmenities => 'Amenities';

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visits',
      one: '1 visit',
    );
    return '$_temp0';
  }
}
