import 'package:dio/dio.dart';

/// Central point for API configuration.
class ApiConstants {
  ApiConstants._();

  static const String overpassBaseUrl = 'https://overpass-api.de';
  static const String overpassPath = '/api/interpreter';

  static const String dalilBaseUrl = 'https://dalildimashq.com/api/v1';
  static const String randomCategoriesPath = '$dalilBaseUrl/categories/random';
  static const String categoriesPath = '$dalilBaseUrl/categories';

  static const String randomRegionsPath = '$dalilBaseUrl/regions/random';
  static const String regionsPath = '$dalilBaseUrl/regions';
  static const String bannersPath = '$dalilBaseUrl/banners';
  static const String favoritesServicesPath =
      '$dalilBaseUrl/favorites/services';
  static const String topRatedServicesPath = '$dalilBaseUrl/services/top-ten';
  static const String userTopRatedServicesPath =
      '$dalilBaseUrl/user/services/top-ten';

  // The services nearest to the location the app sends. Without one the same
  // path answers with ten picked at random, so both halves need a variant.
  static const String nearbyServicesPath = '$dalilBaseUrl/services/nearby';
  static const String userNearbyServicesPath =
      '$dalilBaseUrl/user/services/nearby';

  // Searching the published services. The signed-in variant is the only one
  // that can say which of the results the user already favorited.
  static const String servicesSearchPath = '$dalilBaseUrl/services/search';
  static const String userServicesSearchPath =
      '$dalilBaseUrl/user/services/search';

  // One service's own profile: the public reading and the bearer-token one
  // that can also say whether the reader favorited it.
  static String serviceDetailPath(String slug) =>
      '$dalilBaseUrl/services/${Uri.encodeComponent(slug)}';
  static String userServiceDetailPath(String slug) =>
      '$dalilBaseUrl/user/services/${Uri.encodeComponent(slug)}';

  // The pictures, the menu and the opinions under that service. The menu
  // answers whole or narrowed to one of its own categories.
  static String serviceImagesPath(String slug) =>
      '${serviceDetailPath(slug)}/images';
  static String serviceProductsPath(String slug) =>
      '${serviceDetailPath(slug)}/products';
  static String serviceProductCategoriesPath(String slug) =>
      '${serviceDetailPath(slug)}/categories';
  static String serviceCategoryProductsPath(String slug, String categorySlug) =>
      '${serviceProductCategoriesPath(slug)}/${Uri.encodeComponent(categorySlug)}/products';

  // The signed-in reviews path is spelled without a slash by the backend.
  static String serviceReviewsPath(String slug) =>
      '${serviceDetailPath(slug)}/reviews';
  static String userServiceReviewsPath(String slug) =>
      '$dalilBaseUrl/userservices/${Uri.encodeComponent(slug)}/reviews';

  static const String authRegisterPath = '$dalilBaseUrl/auth/register';
  static const String authLoginPath = '$dalilBaseUrl/auth/login';

  static const String profilePath = '$dalilBaseUrl/user/profile';
  static const String profileAvatarPath = '$profilePath/avatar';
  static const String profilePasswordPath = '$profilePath/change-password';
  static const String profileAccountPath = '$profilePath/account';

  static const String vendorServicePath = '$dalilBaseUrl/vendor/service';
  static const String vendorMainImagePath = '$vendorServicePath/main-image';
  static const String vendorAccountPasswordPath =
      '$vendorServicePath/account/change-password';

  // The two pick lists the join form searches, and the application itself.
  static const String vendorRegionsPath = '$dalilBaseUrl/vendor/regions';
  static const String vendorCategoriesPath = '$dalilBaseUrl/vendor/categories';
  static const String vendorJoinRequestPath =
      '$dalilBaseUrl/vendor/join-request';

  // The vendor's own contact lines: the types on offer and the six calls that
  // read and write them.
  static const String vendorContactsPath = '$dalilBaseUrl/vendor/contacts';
  static const String vendorContactTypesPath = '$vendorContactsPath/types';
  static String vendorContactPath(int id) => '$vendorContactsPath/$id';
  static String vendorContactPrimaryPath(int id) =>
      '${vendorContactPath(id)}/set-primary';

  // The pictures under the vendor's service: one list, one upload, and two
  // deletions — a single picture or the whole set.
  static const String vendorImagesPath = '$dalilBaseUrl/vendor/images';
  static String vendorImagePath(int id) => '$vendorImagesPath/$id';

  // What the vendor sells: the categories products are filed under, and the
  // products themselves — listed, written and deleted by id.
  static const String vendorProductsPath = '$dalilBaseUrl/vendor/products';
  static const String vendorProductCategoriesPath =
      '$dalilBaseUrl/vendor/product-categories';
  static String vendorProductPath(int id) => '$vendorProductsPath/$id';

  // What the vendor offers besides its goods: the list carries the limit, and
  // one amenity is rewritten, removed by id or cleared all at once.
  static const String vendorAmenitiesPath = '$dalilBaseUrl/vendor/amenities';
  static String vendorAmenityPath(int id) => '$vendorAmenitiesPath/$id';

  // What the vendor posts as a story: one call, and the `type` it is sent
  // decides whether a picture, a clip or a poll rides with it.
  static const String vendorStoriesPath = '$dalilBaseUrl/vendor/stories';

  // What the readers see: the same stories, listed to anyone who asks, page by
  // page. No sign-in rides on this one.
  static const String storiesPath = '$dalilBaseUrl/stories';

  // Everything one service posted, newest first — the archive behind its story.
  static String storiesServicePath(int id) => '$storiesPath/service/$id';

  // What a signed-in reader does with one of those stories: say they watched
  // it, and answer its poll. Both are addressed by the story's own id.
  static const String userStoriesPath = '$dalilBaseUrl/user/stories';
  static String storyViewPath(int id) => '$userStoriesPath/$id/view';
  static String storyPollVotePath(int id) => '$userStoriesPath/$id/poll/vote';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String userAgent = 'DaliAlsham/1.0';
}

/// Creates the shared [Dio] instance used by all remote data sources.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.overpassBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'User-Agent': ApiConstants.userAgent},
      responseType: ResponseType.json,
    ),
  );
  return dio;
}
