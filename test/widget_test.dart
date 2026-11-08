import 'dart:async';
import 'dart:convert' show base64Decode;
import 'dart:typed_data';

import 'package:dali_alsham/app/app.dart';
import 'package:dali_alsham/app/app_bottom_bar.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/locale_repository.dart';
import 'package:dali_alsham/core/settings/domain/theme_repository.dart';
import 'package:dali_alsham/core/settings/domain/token_repository.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/core/widgets/shimmer.dart';
import 'package:dali_alsham/di/injection.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_session.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_user.dart';
import 'package:dali_alsham/features/auth/domain/entities/credentials.dart';
import 'package:dali_alsham/features/auth/domain/entities/join_request.dart';
import 'package:dali_alsham/features/auth/domain/entities/registration.dart';
import 'package:dali_alsham/features/auth/domain/repositories/auth_repository.dart';
import 'package:dali_alsham/features/auth/presentation/pages/login_page.dart';
import 'package:dali_alsham/features/auth/presentation/pages/register_page.dart';
import 'package:dali_alsham/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/usecases/get_banners.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_category_page.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_random_categories.dart';
import 'package:dali_alsham/features/categories/presentation/pages/categories_page.dart';
import 'package:dali_alsham/features/categories/presentation/widgets/category_pills.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:dali_alsham/features/chat/domain/repositories/chat_repository.dart';
import 'package:dali_alsham/features/chat/presentation/pages/chat_page.dart';
import 'package:dali_alsham/features/favorites/domain/entities/favorite_mutation.dart';
import 'package:dali_alsham/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/get_current_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/has_location_access.dart';
import 'package:dali_alsham/features/onboarding/domain/onboarding_repository.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:dali_alsham/features/places/domain/repositories/stories_seen_repository.dart';
import 'package:dali_alsham/features/places/domain/usecases/get_nearby_places.dart';
import 'package:dali_alsham/features/places/presentation/pages/stories_page.dart';
import 'package:dali_alsham/features/places/presentation/widgets/advertise_bar.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_stories_bar.dart';
import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dali_alsham/features/stories/domain/usecases/get_service_story_feed.dart';
import 'package:dali_alsham/features/stories/domain/usecases/get_story_feed.dart';
import 'package:dali_alsham/features/stories/domain/usecases/record_story_view.dart';
import 'package:dali_alsham/features/stories/domain/usecases/vote_story_poll.dart';
import 'package:dali_alsham/features/stories/presentation/cubit/story_feed_cubit.dart';
import 'package:dali_alsham/features/stories/presentation/pages/service_stories_page.dart';
import 'package:dali_alsham/features/stories/presentation/pages/service_story_list_page.dart';
import 'package:dali_alsham/features/stories/presentation/widgets/story_strip.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/profile/domain/entities/profile_edit.dart';
import 'package:dali_alsham/features/profile/domain/repositories/avatar_picker.dart';
import 'package:dali_alsham/features/profile/domain/repositories/profile_repository.dart';
import 'package:dali_alsham/features/profile/presentation/pages/change_password_page.dart';
import 'package:dali_alsham/features/profile/presentation/pages/profile_page.dart';
import 'package:dali_alsham/features/vendor/domain/entities/contact_group.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_gallery.dart';
import 'package:dali_alsham/features/vendor/domain/entities/contact_type.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image_gallery.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_page.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_query.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story_edit.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/story_file_picker.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_amenity_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_contact_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_image_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_picker_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_product_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_repository.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_story_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_amenities_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_amenity_form_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_contact_form_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_contacts_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_images_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_join_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_password_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_product_form_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_products_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_service_page.dart';
import 'package:dali_alsham/features/vendor/presentation/pages/vendor_story_form_page.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_random_regions.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_region_page.dart';
import 'package:dali_alsham/features/regions/presentation/pages/regions_page.dart';
import 'package:dali_alsham/features/regions/presentation/widgets/region_rail.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/entities/service_search_query.dart';
import 'package:dali_alsham/features/services/domain/entities/service_sort.dart';
import 'package:dali_alsham/features/services/domain/usecases/get_service_page.dart';
import 'package:dali_alsham/features/services/domain/usecases/search_services.dart';
import 'package:dali_alsham/features/services/presentation/pages/services_page.dart';
import 'package:dali_alsham/features/services/presentation/pages/services_search_page.dart';
import 'package:dali_alsham/features/services/presentation/widgets/nearby_rail.dart';
import 'package:dali_alsham/features/services/presentation/widgets/service_card.dart';
import 'package:dali_alsham/features/services/presentation/widgets/top_rated_rail.dart';
import 'package:dali_alsham/features/tutorial/domain/tutorial_repository.dart';
import 'package:dali_alsham/features/tutorial/presentation/feature_tour.dart';
import 'package:dali_alsham/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _MockLocaleRepository extends Mock implements LocaleRepository {}

class _MockThemeRepository extends Mock implements ThemeRepository {}

class _MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class _MockHasLocationAccess extends Mock implements HasLocationAccess {}

class _MockGetNearbyPlaces extends Mock implements GetNearbyPlaces {}

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class _MockStoriesSeenRepository extends Mock
    implements StoriesSeenRepository {}

class _MockTutorialRepository extends Mock implements TutorialRepository {}

class _MockGetRandomCategories extends Mock implements GetRandomCategories {}

class _MockGetCategoryPage extends Mock implements GetCategoryPage {}

class _MockGetBanners extends Mock implements GetBanners {}

class _MockGetRandomRegions extends Mock implements GetRandomRegions {}

class _MockGetRegionPage extends Mock implements GetRegionPage {}

class _MockGetServicePage extends Mock implements GetServicePage {}

class _MockSearchServices extends Mock implements SearchServices {}

class _MockGetStoryFeed extends Mock implements GetStoryFeed {}

class _MockGetServiceStoryFeed extends Mock implements GetServiceStoryFeed {}

class _MockRecordStoryView extends Mock implements RecordStoryView {}

class _MockVoteStoryPoll extends Mock implements VoteStoryPoll {}

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockTokenRepository extends Mock implements TokenRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAvatarPicker extends Mock implements AvatarPicker {}

class _MockVendorRepository extends Mock implements VendorRepository {}

class _MockVendorPickerRepository extends Mock
    implements VendorPickerRepository {}

class _MockVendorContactRepository extends Mock
    implements VendorContactRepository {}

class _MockVendorImageRepository extends Mock
    implements VendorImageRepository {}

class _MockVendorProductRepository extends Mock
    implements VendorProductRepository {}

class _MockVendorAmenityRepository extends Mock
    implements VendorAmenityRepository {}

class _MockVendorStoryRepository extends Mock implements VendorStoryRepository {
}

class _MockStoryFilePicker extends Mock implements StoryFilePicker {}

Future<void> _pumpSplash(
  WidgetTester tester, {
  bool onboardingCompleted = true,
  bool tutorialCompleted = true,
  Result<UserLocation>? location,
  Result<NearbyPlaces>? places,
  List<Story> stories = const [],
  String? token,
  AuthUser? account,
}) async {
  getIt.registerSingleton<LocaleRepository>(_MockLocaleRepository());
  getIt.registerSingleton<ThemeRepository>(_MockThemeRepository());
  getIt.registerSingleton<GetCurrentLocation>(_MockGetCurrentLocation());
  getIt.registerSingleton<HasLocationAccess>(_MockHasLocationAccess());
  getIt.registerSingleton<GetNearbyPlaces>(_MockGetNearbyPlaces());
  getIt.registerSingleton<OnboardingRepository>(_MockOnboardingRepository());
  getIt.registerSingleton<StoriesSeenRepository>(_MockStoriesSeenRepository());
  getIt.registerSingleton<TutorialRepository>(_MockTutorialRepository());
  getIt.registerSingleton<GetRandomCategories>(_MockGetRandomCategories());
  getIt.registerSingleton<GetCategoryPage>(_MockGetCategoryPage());
  getIt.registerSingleton<GetBanners>(_MockGetBanners());
  getIt.registerSingleton<GetRandomRegions>(_MockGetRandomRegions());
  getIt.registerSingleton<GetRegionPage>(_MockGetRegionPage());
  getIt.registerSingleton<GetServicePage>(_MockGetServicePage());
  getIt.registerSingleton<SearchServices>(_MockSearchServices());
  getIt.registerSingleton<GetStoryFeed>(_MockGetStoryFeed());
  getIt.registerSingleton<GetServiceStoryFeed>(_MockGetServiceStoryFeed());
  getIt.registerSingleton<RecordStoryView>(_MockRecordStoryView());
  getIt.registerSingleton<VoteStoryPoll>(_MockVoteStoryPoll());
  getIt.registerSingleton<ChatRepository>(_MockChatRepository());
  getIt.registerSingleton<TokenRepository>(_MockTokenRepository());
  getIt.registerSingleton<FavoritesRepository>(_MockFavoritesRepository());
  getIt.registerSingleton<AuthRepository>(_MockAuthRepository());
  getIt.registerSingleton<ProfileRepository>(_MockProfileRepository());
  getIt.registerSingleton<AvatarPicker>(_MockAvatarPicker());
  getIt.registerSingleton<VendorRepository>(_MockVendorRepository());
  getIt.registerSingleton<VendorPickerRepository>(
    _MockVendorPickerRepository(),
  );
  getIt.registerSingleton<VendorContactRepository>(
    _MockVendorContactRepository(),
  );
  getIt.registerSingleton<VendorImageRepository>(_MockVendorImageRepository());
  getIt.registerSingleton<VendorProductRepository>(
    _MockVendorProductRepository(),
  );
  getIt.registerSingleton<VendorAmenityRepository>(
    _MockVendorAmenityRepository(),
  );
  getIt.registerSingleton<VendorStoryRepository>(_MockVendorStoryRepository());
  getIt.registerSingleton<StoryFilePicker>(_MockStoryFilePicker());

  when(
    () => getIt<LocaleRepository>().getLocaleCode(),
  ).thenAnswer((_) async => 'en');
  when(
    () => getIt<LocaleRepository>().saveLocaleCode(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<ThemeRepository>().getThemeMode(),
  ).thenAnswer((_) async => 'system');
  when(
    () => getIt<ThemeRepository>().saveThemeMode(any()),
  ).thenAnswer((_) async {});
  // Storage that answers what it was last handed, so signing in or out moves
  // every screen that switches on a bearer token.
  var storedToken = token;
  when(
    () => getIt<TokenRepository>().getToken(),
  ).thenAnswer((_) async => storedToken);
  when(() => getIt<TokenRepository>().saveToken(any())).thenAnswer((
    invocation,
  ) async {
    storedToken = invocation.positionalArguments.single as String;
  });
  when(() => getIt<TokenRepository>().clearToken()).thenAnswer((_) async {
    storedToken = null;
  });
  when(
    () => getIt<FavoritesRepository>().add(any()),
  ).thenAnswer((_) async => const Success(FavoriteMutation(isFavorited: true)));
  when(() => getIt<FavoritesRepository>().remove(any())).thenAnswer(
    (_) async => const Success(FavoriteMutation(isFavorited: false)),
  );
  when(
    () => getIt<AuthRepository>().account(),
  ).thenAnswer((_) async => account);
  when(
    () => getIt<AuthRepository>().signOut(),
  ).thenAnswer((_) => getIt<TokenRepository>().clearToken());
  when(() => getIt<AuthRepository>().login(any())).thenAnswer(
    (_) async => const FailureResult(
      ServerFailure('These credentials do not match our records.'),
    ),
  );
  when(() => getIt<AuthRepository>().register(any())).thenAnswer(
    (_) async => const FailureResult(
      ServerFailure('The mobile has already been taken.'),
    ),
  );
  when(
    () => getIt<ProfileRepository>().load(any()),
  ).thenAnswer((_) async => const Success(_profile));
  when(
    () => getIt<ProfileRepository>().update(
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_profile));
  when(
    () => getIt<ProfileRepository>().uploadAvatar(
      file: any(named: 'file'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer(
    (_) async =>
        const Success('https://dalildimashq.com/storage/avatars/99.jpg'),
  );
  when(
    () => getIt<ProfileRepository>().removeAvatar(),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<ProfileRepository>().changePassword(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<ProfileRepository>().deleteAccount(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  when(() => getIt<AvatarPicker>().pick()).thenAnswer((_) async => null);
  when(
    () => getIt<StoryFilePicker>().pickImage(),
  ).thenAnswer((_) async => null);
  when(
    () => getIt<StoryFilePicker>().pickVideo(),
  ).thenAnswer((_) async => null);
  when(
    () => getIt<VendorStoryRepository>().add(
      edit: any(named: 'edit'),
      file: any(named: 'file'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_postedStory));
  when(
    () => getIt<VendorRepository>().load(any()),
  ).thenAnswer((_) async => const Success(_vendorService));
  when(
    () => getIt<VendorRepository>().update(
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorRepository>().removeMainImage(),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorRepository>().changePassword(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorPickerRepository>().regions(
      locale: any(named: 'locale'),
      query: any(named: 'query'),
    ),
  ).thenAnswer(
    (_) async => const Success(<Region>[
      Region(id: 1, name: 'المزة'),
      Region(id: 2, name: 'ابن العماد'),
    ]),
  );
  when(
    () => getIt<VendorPickerRepository>().categories(
      locale: any(named: 'locale'),
      query: any(named: 'query'),
    ),
  ).thenAnswer(
    (_) async =>
        const Success(<ExploreCategory>[ExploreCategory(id: 4, name: 'مطاعم')]),
  );
  when(
    () =>
        getIt<VendorContactRepository>().contacts(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(_contactGroups));
  when(
    () => getIt<VendorContactRepository>().types(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(_contactTypes));
  when(
    () => getIt<VendorContactRepository>().add(
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_whatsappContact));
  when(
    () => getIt<VendorContactRepository>().update(
      id: any(named: 'id'),
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_whatsappContact));
  when(
    () => getIt<VendorContactRepository>().remove(
      id: any(named: 'id'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorContactRepository>().setPrimary(
      id: any(named: 'id'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_primaryPhone));
  // The vendor's own photo set: the gallery, the limit it carries, and the two
  // deletions.
  when(
    () => getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(_vendorImages));
  when(
    () => getIt<VendorImageRepository>().add(
      file: any(named: 'file'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_vendorImageAdded));
  when(
    () => getIt<VendorImageRepository>().remove(
      id: any(named: 'id'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorImageRepository>().clear(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(2));
  // The vendor's own products: the listing answers page by page and records
  // every query it was sent, the categories the form picks from, and the three
  // writes.
  _productRequests.clear();
  when(() => getIt<VendorProductRepository>().products(any())).thenAnswer((
    invocation,
  ) async {
    _productRequests.add(
      invocation.positionalArguments.single as VendorProductQuery,
    );
    return const Success(_vendorProducts);
  });
  when(
    () => getIt<VendorProductRepository>().categories(
      locale: any(named: 'locale'),
      query: any(named: 'query'),
    ),
  ).thenAnswer(
    (_) async => const Success(<ExploreCategory>[
      ExploreCategory(id: 4, name: 'مقاهي'),
      ExploreCategory(id: 5, name: 'حلويات'),
    ]),
  );
  when(
    () => getIt<VendorProductRepository>().add(
      edit: any(named: 'edit'),
      image: any(named: 'image'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_coffeeProduct));
  when(
    () => getIt<VendorProductRepository>().update(
      id: any(named: 'id'),
      edit: any(named: 'edit'),
      image: any(named: 'image'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_juiceProduct));
  when(
    () => getIt<VendorProductRepository>().remove(
      id: any(named: 'id'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success<void>(null));
  // What the vendor offers: the read carries the limit, and the four writes
  // answer with the line they stored.
  when(
    () =>
        getIt<VendorAmenityRepository>().gallery(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(_vendorAmenities));
  when(
    () => getIt<VendorAmenityRepository>().add(
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_hallAmenity));
  when(
    () => getIt<VendorAmenityRepository>().update(
      id: any(named: 'id'),
      edit: any(named: 'edit'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success(_hallAmenity));
  when(
    () => getIt<VendorAmenityRepository>().remove(
      id: any(named: 'id'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => getIt<VendorAmenityRepository>().clear(locale: any(named: 'locale')),
  ).thenAnswer((_) async => const Success(2));
  when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
    (_) async => location ?? const FailureResult(LocationPermissionFailure()),
  );
  when(() => getIt<HasLocationAccess>()()).thenAnswer((_) async => false);
  when(
    () => getIt<GetNearbyPlaces>().call(any()),
  ).thenAnswer((_) async => places ?? const Success(NearbyPlaces(places: [])));
  when(
    () => getIt<OnboardingRepository>().hasCompleted(),
  ).thenAnswer((_) async => onboardingCompleted);
  when(
    () => getIt<OnboardingRepository>().markCompleted(),
  ).thenAnswer((_) async {});
  when(
    () => getIt<StoriesSeenRepository>().getViewedIds(),
  ).thenAnswer((_) async => <String>{});
  when(
    () => getIt<StoriesSeenRepository>().saveViewedIds(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<TutorialRepository>().hasCompleted(),
  ).thenAnswer((_) async => tutorialCompleted);
  when(
    () => getIt<TutorialRepository>().setCompleted(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<GetRandomCategories>().call(any()),
  ).thenAnswer((_) async => const Success<List<ExploreCategory>>([]));
  when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
    (_) async => const Success(CategoryPage(categories: [], hasMore: false)),
  );
  when(
    () => getIt<GetBanners>().call(any()),
  ).thenAnswer((_) async => const Success<List<BannerAd>>([]));
  when(
    () => getIt<GetRandomRegions>().call(any()),
  ).thenAnswer((_) async => const Success<List<Region>>([]));
  when(() => getIt<GetRegionPage>().call(any())).thenAnswer(
    (_) async => const Success(RegionPage(regions: [], hasMore: false)),
  );
  when(() => getIt<GetServicePage>().call(any())).thenAnswer(
    (_) async => const Success(ServicePage(services: [], hasMore: false)),
  );
  _searchLog.clear();
  when(() => getIt<SearchServices>().call(any())).thenAnswer((
    invocation,
  ) async {
    _searchLog.add(invocation.positionalArguments.single as ServiceSearchQuery);
    return const Success(ServicePage(services: [], hasMore: false));
  });
  // An empty listing leaves the stories row to the nearby places; a test that
  // hands stories takes the row over.
  when(
    () => getIt<GetStoryFeed>().call(any()),
  ).thenAnswer(
    (_) async => Success(StoryFeed(stories: stories, hasMore: false)),
  );
  // A signed-in reader's view and vote both land, unless a test says otherwise.
  when(
    () => getIt<RecordStoryView>().call(any()),
  ).thenAnswer((_) async => const Success('View recorded'));
  when(
    () => getIt<VoteStoryPoll>().call(any()),
  ).thenAnswer((_) async => const Success('Vote recorded'));
  // The archive behind a service's story. By default the service has posted
  // nothing beyond the page the strip shows, so a tap plays the strip's own
  // set; a test that gathers a whole archive says so itself.
  when(
    () => getIt<GetServiceStoryFeed>().call(any()),
  ).thenAnswer(
    (_) async => Success(StoryFeed(stories: const [], hasMore: false)),
  );
  when(
    () => getIt<ChatRepository>().getMessages(
      placeId: any(named: 'placeId'),
      placeName: any(named: 'placeName'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => Success<List<ChatMessage>>([]));
  when(
    () => getIt<ChatRepository>().sendMessage(
      placeId: any(named: 'placeId'),
      text: any(named: 'text'),
    ),
  ).thenAnswer(
    (_) async => Success(
      ChatMessage(
        id: 'local/1',
        author: '',
        text: 'placeholder',
        createdAt: DateTime(2026, 10, 27, 21),
        isMine: true,
      ),
    ),
  );

  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const DaliAlshamApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// A platform that answers for clips. The viewer asks the decoder and carries
/// the reader on either way, so the build behind the test answers where a
/// machine with no video hardware cannot.
class _AnswersForClips extends VideoPlayerPlatform {
  final _events = StreamController<VideoEvent>.broadcast();
  int _playerId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    _playerId++;
    // The metadata arrives after the slide was drawn, the way a real decoder
    // answers a frame late; the page has to notice the clip on its own.
    Future<void>.delayed(
      const Duration(milliseconds: 600),
      () => _events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 8),
          size: const Size(720, 1280),
        ),
      ),
    );
    return _playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events.stream;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.orange, key: ValueKey('clip-on-screen'));

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> dispose(int playerId) async {}
}

Future<void> _pumpApp(
  WidgetTester tester, {
  bool tutorialCompleted = true,
  Result<UserLocation>? location,
  Result<NearbyPlaces>? places,
  List<Story> stories = const [],
  String? token,
  AuthUser? account,
}) async {
  await _pumpSplash(
    tester,
    tutorialCompleted: tutorialCompleted,
    location: location,
    places: places,
    stories: stories,
    token: token,
    account: account,
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// A poll, a clip and a picture, as the public listing hands them to the strip.
const _serviceStories = [
  Story(
    id: 5,
    type: StoryType.poll,
    caption: 'عرض جديد اليوم',
    hoursLeft: 21,
    service: StoryService(id: 1, name: 'الاسد'),
    poll: StoryPoll(
      id: 2,
      question: 'ما هو طبقك المفضل؟',
      totalVotes: 10,
      options: [
        StoryPollOption(id: 4, text: 'شاورما', votesCount: 7),
        StoryPollOption(id: 5, text: 'فلافل', votesCount: 3),
      ],
    ),
  ),
  Story(
    id: 3,
    type: StoryType.video,
    videoUrl: 'https://dalildimashq.com/storage/stories/3.mp4',
    service: StoryService(id: 1, name: 'الاسد'),
  ),
  Story(
    id: 2,
    type: StoryType.image,
    imageUrl: 'https://dalildimashq.com/storage/stories/2.png',
    caption: 'عرض جديد اليوم',
    service: StoryService(id: 1, name: 'الاسد'),
  ),
];

/// Everything one service posted, which is the set the strip mixed together and
/// the feed cut off after its newest page.
const _serviceArchive = [
  Story(
    id: 6,
    type: StoryType.poll,
    caption: 'عرض جديد اليوم',
    hoursLeft: 23,
    service: StoryService(id: 1, name: 'الاسد'),
    poll: StoryPoll(
      id: 3,
      question: 'ما هو طبقك المفضل؟',
      totalVotes: 0,
      options: [
        StoryPollOption(id: 8, text: 'شاورما', votesCount: 0),
        StoryPollOption(id: 9, text: 'فلافل', votesCount: 0),
        StoryPollOption(id: 10, text: 'برجر', votesCount: 0),
      ],
    ),
  ),
  Story(
    id: 4,
    type: StoryType.poll,
    caption: 'عرض جديد اليوم',
    hoursLeft: 22,
    service: StoryService(id: 1, name: 'الاسد'),
    poll: StoryPoll(
      id: 1,
      question: 'متى تزورنا؟',
      totalVotes: 1,
      options: [
        StoryPollOption(id: 1, text: 'صباحاً', votesCount: 1),
        StoryPollOption(id: 2, text: 'مساءً', votesCount: 0),
      ],
    ),
  ),
  Story(
    id: 3,
    type: StoryType.video,
    videoUrl: 'https://dalildimashq.com/storage/stories/3.mp4',
    caption: 'عرض جديد اليوم',
    hoursLeft: 21,
    service: StoryService(id: 1, name: 'الاسد'),
  ),
  Story(
    id: 2,
    type: StoryType.image,
    imageUrl: 'https://dalildimashq.com/storage/stories/2.png',
    caption: 'عرض جديد اليوم',
    hoursLeft: 20,
    service: StoryService(id: 1, name: 'الاسد'),
  ),
];

/// Out of the strip and into the viewer. A tap gathers the service's whole
/// archive first, so a test that wants one says so before calling this.
Future<void> _openServiceViewer(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('story-card-5')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// From the viewer, through the story's service row, into the archive behind it.
Future<void> _openServiceArchive(WidgetTester tester) async {
  await _openServiceViewer(tester);
  await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// The whole set one service posted, newest first: the three the strip mixed
/// together, plus the older ones its page cut off.
const _serviceWholeSet = [
  Story(
    id: 5,
    type: StoryType.poll,
    caption: 'عرض جديد اليوم',
    hoursLeft: 21,
    service: StoryService(id: 1, name: 'الاسد'),
    poll: StoryPoll(
      id: 2,
      question: 'ما هو طبقك المفضل؟',
      totalVotes: 10,
      options: [
        StoryPollOption(id: 4, text: 'شاورما', votesCount: 7),
        StoryPollOption(id: 5, text: 'فلافل', votesCount: 3),
      ],
    ),
  ),
  Story(
    id: 4,
    type: StoryType.poll,
    caption: 'عرض جديد اليوم',
    hoursLeft: 22,
    service: StoryService(id: 1, name: 'الاسد'),
    poll: StoryPoll(
      id: 1,
      question: 'متى تزورنا؟',
      totalVotes: 1,
      options: [
        StoryPollOption(id: 1, text: 'صباحاً', votesCount: 1),
        StoryPollOption(id: 2, text: 'مساءً', votesCount: 0),
      ],
    ),
  ),
  Story(
    id: 3,
    type: StoryType.video,
    videoUrl: 'https://dalildimashq.com/storage/stories/3.mp4',
    service: StoryService(id: 1, name: 'الاسد'),
  ),
  Story(
    id: 2,
    type: StoryType.image,
    imageUrl: 'https://dalildimashq.com/storage/stories/2.png',
    caption: 'عرض جديد اليوم',
    service: StoryService(id: 1, name: 'الاسد'),
  ),
];

/// The page that follows it, which the strip never showed at all.
const _serviceWholeSetNextPage = [
  Story(
    id: 1,
    type: StoryType.image,
    imageUrl: 'https://dalildimashq.com/storage/stories/1.png',
    caption: 'خصم على القائمة',
    hoursLeft: 8,
    service: StoryService(id: 1, name: 'الاسد'),
  ),
];

/// The service's archive as a tap gathers it: [pages] answered one after
/// another, each offering the next until the last, which offers none.
void _stubArchivePages(
  List<List<Story>> pages, {
  Failure? failure,
}) {
  when(
    () => getIt<GetServiceStoryFeed>().call(any()),
  ).thenAnswer((invocation) async {
    if (failure != null) return FailureResult<StoryFeed>(failure);
    final params =
        invocation.positionalArguments.single as ServiceStoryFeedParams;
    final index = params.page - 1;
    final follows = index + 1 < pages.length;
    return Success(
      StoryFeed(
        stories: index < pages.length ? pages[index] : const <Story>[],
        hasMore: follows,
        nextPage: follows ? params.page + 1 : null,
      ),
    );
  });
}

/// The list under the search field holds services, so a place profile is
/// reached through its story.
Future<void> _openPlaceProfile(
  WidgetTester tester, {
  String id = 'node/1',
}) async {
  await tester.tap(find.byKey(ValueKey('story-ring-$id')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  final open = find.byKey(const ValueKey('story-open-place')).first;
  await tester.ensureVisible(open);
  await tester.pump();
  await tester.tap(open);
  await tester.pumpAndSettle();
}

/// The home top-rated rail shares [GetServicePage] with the listing pages, so
/// the listing request is the most recent one rather than the only one.
ServicePageParams _lastServicePageRequest() => _servicePageRequests.last;

Iterable<ServicePageParams> get _servicePageRequests => verify(
  () => getIt<GetServicePage>().call(captureAny()),
).captured.cast<ServicePageParams>();

/// The home feed carries two short listings at once, so a rail test names the
/// scope whose request it wants to read.
ServicePageParams _lastServicePageRequestOf(ServiceScope scope) =>
    _servicePageRequests.lastWhere((params) => params.scope == scope);

/// Two rows the feed under the search field can be counted against.
const _feedServices = [
  ServiceSummary(
    id: 5,
    name: 'Nawfara Cafe',
    categoryName: 'Cafés',
    regionName: 'Al Fazari',
    distanceText: '400 m',
  ),
  ServiceSummary(
    id: 6,
    name: 'Al Baraka Bakery',
    categoryName: 'Bakeries',
    regionName: 'Barzeh',
    distanceText: '1 km',
  ),
];

/// The feed shares [GetServicePage] with both rails and answers page by page,
/// so a feed test replies per scope and then asks the page to reload.
Future<void> _stubFeed(
  WidgetTester tester, {
  List<ServiceSummary>? firstPage,
  List<ServiceSummary>? secondPage,
  Failure? failure,
}) async {
  when(() => getIt<GetServicePage>().call(any())).thenAnswer((
    invocation,
  ) async {
    final params = invocation.positionalArguments.single as ServicePageParams;
    if (params.scope != ServiceScope.nearby) {
      return const Success(ServicePage(services: [], hasMore: false));
    }
    if (failure != null) return FailureResult(failure);
    if (params.page > 1) {
      return Success(
        ServicePage(services: secondPage ?? const [], hasMore: false),
      );
    }
    return Success(
      ServicePage(
        services: firstPage ?? _feedServices,
        hasMore: secondPage != null,
        nextPage: secondPage != null ? 2 : null,
      ),
    );
  });

  await tester.tap(find.byTooltip('Retry'));
  await tester.pumpAndSettle();
}

/// The rows each home listing keeps between one pull and the next. The rail
/// and the list under the search field read the same nearby page, and the rest
/// of the directory answers with nothing, as it did before the pull.
List<ServiceSummary> _keptRows(ServicePageParams params) =>
    switch (params.scope) {
      ServiceScope.nearby || ServiceScope.topRated => _feedServices,
      _ => const <ServiceSummary>[],
    };

/// The header filter shares [GetServicePage] with the feed and the rails, so a
/// region test answers per scope too: the region page carries its own place.
void _stubRegionFeed() {
  when(() => getIt<GetServicePage>().call(any())).thenAnswer((
    invocation,
  ) async {
    final params = invocation.positionalArguments.single as ServicePageParams;
    return switch (params.scope) {
      ServiceScope.region => const Success(
        ServicePage(
          services: [ServiceSummary(id: 88, name: 'Mazzeh Grill')],
          hasMore: false,
        ),
      ),
      ServiceScope.nearby => const Success(
        ServicePage(services: _feedServices, hasMore: false),
      ),
      _ => const Success(ServicePage(services: [], hasMore: false)),
    };
  });
}

/// A row of the sheet the header filter opens. The page behind the sheet can
/// carry the same words in its title, so the tap is aimed inside the sheet.
Finder _sheetOption(String name) => find.descendant(
  of: find.byType(BottomSheet),
  matching: find.text(name),
);

/// The showcase behind the tabs, answered per test so a refresh can hand back a
/// different set of categories.
void _stubCategories(List<ExploreCategory> categories) {
  when(
    () => getIt<GetRandomCategories>().call(any()),
  ).thenAnswer((_) async => Success<List<ExploreCategory>>(categories));
}

/// The pills sit above the list, and a short test window leaves them out of
/// reach; a tall one keeps every section of the home page laid out.
void _showWholeFeed(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Whether the pill with this key is drawn as the chosen one: only that circle
/// carries the glyph in the colour of a filled surface.
bool _pillIsChosen(WidgetTester tester, String key) {
  final location = find.byKey(ValueKey(key));
  final icon = tester.widget<Icon>(
    find.descendant(of: location, matching: find.byType(Icon)),
  );
  return icon.color == Theme.of(tester.element(location)).colorScheme.onPrimary;
}

/// Only the search page asks [SearchServices] for anything, so the log is one
/// entry per trip from the field or from one of the four filters. A test that
/// reads it more than once would have to re-verify the same call, so the mock
/// writes it here instead.
final _searchLog = <ServiceSearchQuery>[];

ServiceSearchQuery _lastSearchRequest() => _searchLog.last;

/// Typing in the home field narrows the feed; the keyboard action hands the
/// words to the backend search instead.
Future<void> _openBackendSearch(WidgetTester tester, String words) async {
  await tester.enterText(find.byType(TextField), words);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void _stubSearchResults(List<ServiceSummary> services, {int? nextPage}) {
  when(() => getIt<SearchServices>().call(any())).thenAnswer((
    invocation,
  ) async {
    _searchLog.add(invocation.positionalArguments.single as ServiceSearchQuery);
    return Success(
      ServicePage(
        services: services,
        hasMore: nextPage != null,
        nextPage: nextPage,
      ),
    );
  });
}

void _stubSearchFailure() {
  when(() => getIt<SearchServices>().call(any())).thenAnswer((
    invocation,
  ) async {
    _searchLog.add(invocation.positionalArguments.single as ServiceSearchQuery);
    return const FailureResult(ServerFailure());
  });
}

/// The two menus that do not need a pick list: the order and the rating. The
/// bar scrolls sideways, so the button is brought on screen first.
Future<void> _chooseFromMenu(
  WidgetTester tester,
  String buttonKey,
  String option,
) async {
  final button = find.byKey(ValueKey(buttonKey));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
}

const _imran = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  locale: 'en',
);

const _profile = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  gender: 'male',
  address: 'Straight Street',
  locale: 'en',
);

/// The same account, but flagged as a vendor — the only kind that owns a
/// service the `/vendor/service` endpoints edit.
const _vendorImran = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  locale: 'en',
  type: 'vendor',
);

const _vendorService = VendorService(
  id: 1,
  nameAr: 'الاسد',
  nameEn: 'amran',
  isMain: true,
  regionName: 'المزة',
  categoryName: 'مطاعم',
  addressAr: 'دمشق',
  addressEn: 'damascus',
  googleMapsUrl: 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
  lat: 33,
  descriptionAr: 'عمران',
  descriptionEn: 'amran',
  subscriptionType: 'free',
  mainImage: 'https://dalildimashq.com/storage/join_requests/images/a.png',
);

/// The service after its cover picture is gone.
const _serviceWithoutImage = VendorService(
  id: 1,
  nameAr: 'الاسد',
  nameEn: 'amran',
  isMain: true,
  regionName: 'المزة',
  categoryName: 'مطاعم',
  addressAr: 'دمشق',
  addressEn: 'damascus',
  googleMapsUrl: 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
  lat: 33,
  descriptionAr: 'عمران',
  descriptionEn: 'amran',
  subscriptionType: 'free',
);

final _picked = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'me.jpg',
);

/// The two pictures `GET /vendor/images` answers with. One still waits for an
/// admin, so only that tile carries the badge.
const _vendorImagePair = <VendorImage>[
  VendorImage(
    id: 1,
    url: 'https://dalildimashq.com/storage/vendor/images/1.png',
    isApproved: false,
    sortOrder: 1,
  ),
  VendorImage(
    id: 2,
    url: 'https://dalildimashq.com/storage/vendor/images/2.png',
    isApproved: true,
    sortOrder: 2,
  ),
];

const _vendorImages = VendorImageGallery(
  images: _vendorImagePair,
  maxAllowed: 20,
  canAdd: true,
);

/// The same set once the endpoint says there is no room for a third.
const _vendorImagesFull = VendorImageGallery(
  images: _vendorImagePair,
  maxAllowed: 2,
  canAdd: false,
);

/// A service with no pictures yet, and the one the upload endpoint echoes back.
const _vendorImagesEmpty = VendorImageGallery(
  images: <VendorImage>[],
  maxAllowed: 20,
  canAdd: true,
);

const _vendorImageAdded = VendorImage(
  id: 3,
  url: 'https://dalildimashq.com/storage/vendor/images/3.png',
  isApproved: false,
  sortOrder: 3,
);

/// The two rows `GET /vendor/products` answers with. One still waits for an
/// admin and is hidden, so only those carry a badge.
const _coffeeProduct = VendorProduct(
  id: 3,
  nameAr: 'قهوة',
  nameEn: 'Coffee',
  categoryId: 4,
  categoryName: 'مقاهي',
  price: 1200,
  quantity: 4,
  imageUrl: 'https://dalildimashq.com/storage/vendor/products/3.png',
);

const _juiceProduct = VendorProduct(
  id: 7,
  nameAr: 'عصير',
  price: 9000,
  quantity: 2,
  isApproved: true,
  isActive: false,
);

const _vendorProducts = VendorProductPage(
  products: [_coffeeProduct, _juiceProduct],
  hasMore: true,
  nextPage: 2,
  count: 21,
);

const _vendorProductsEmpty = VendorProductPage(
  products: <VendorProduct>[],
  hasMore: false,
);

/// Every listing request the products page made, so a filter test reads the
/// query that went out instead of only counting calls.
final _productRequests = <VendorProductQuery>[];

VendorProductQuery _lastProductRequest() => _productRequests.last;

/// The two lines `GET /vendor/amenities` answers with. One reached customers
/// and one still waits, so only the second carries a badge.
const _wifiAmenity = VendorAmenity(
  id: 1,
  nameAr: 'واي فاي',
  nameEn: 'Wi-Fi',
  isApproved: true,
  status: 'approved',
);

const _hallAmenity = VendorAmenity(
  id: 2,
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
  isApproved: false,
  status: 'pending',
);

const _vendorAmenities = VendorAmenityGallery(
  amenities: [_wifiAmenity, _hallAmenity],
  maxAllowed: 20,
  canAdd: true,
);

/// The same set once the endpoint says there is no room for a third.
const _vendorAmenitiesFull = VendorAmenityGallery(
  amenities: [_wifiAmenity, _hallAmenity],
  maxAllowed: 2,
  canAdd: false,
);

/// A service that has offered nothing yet.
const _vendorAmenitiesEmpty = VendorAmenityGallery(
  amenities: <VendorAmenity>[],
  maxAllowed: 20,
  canAdd: true,
);

/// The lines `GET /vendor/contacts` groups, and the two types the form offers.
/// Every row carries its group's label; the repository fills it in because the
/// reply names the type only once, on the group.
const _contactGroups = [
  ContactGroup(
    type: 'phone',
    typeLabel: 'هاتف',
    contacts: [
      VendorContact(
        id: 2,
        type: 'phone',
        typeLabel: 'هاتف',
        value: '0999111222',
        isPrimary: true,
      ),
      VendorContact(
        id: 3,
        type: 'phone',
        typeLabel: 'هاتف',
        value: '0999111333',
      ),
    ],
  ),
  ContactGroup(
    type: 'email',
    typeLabel: 'بريد إلكتروني',
    contacts: [
      VendorContact(
        id: 6,
        type: 'email',
        typeLabel: 'بريد إلكتروني',
        value: 'amran1@gmail.com',
      ),
    ],
  ),
];

const _contactTypes = [
  ContactType(value: 'phone', label: 'هاتف'),
  ContactType(value: 'whatsapp', label: 'واتساب'),
];

const _whatsappContact = VendorContact(
  id: 11,
  type: 'whatsapp',
  typeLabel: 'واتساب',
  value: '+9630933314349',
);

const _primaryPhone = VendorContact(
  id: 3,
  type: 'phone',
  value: '0999111333',
  isPrimary: true,
);

/// The signed-in route to the profile: the drawer greets the account by name,
/// and that greeting is the tile the page hangs off.
Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('drawer-account')));
  await tester.pumpAndSettle();
}

/// The vendor form is long, so its lower fields are scrolled into view before
/// they are typed into — a tap on an off-screen field would miss.
Future<void> _scrollAndEnter(
  WidgetTester tester,
  String key,
  String text,
) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
}

Future<void> _openVendorJoin(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('drawer-vendor-join')));
  await tester.pumpAndSettle();
}

Future<void> _fillJoinAccount(WidgetTester tester) async {
  await _scrollAndEnter(tester, 'join-full-name', 'Imran Alsalame');
  await _scrollAndEnter(tester, 'join-mobile', '0944444444');
  await _scrollAndEnter(tester, 'join-password', 'secret1');
  await _scrollAndEnter(tester, 'join-confirm', 'secret1');
}

Future<void> _pickJoinGender(WidgetTester tester) async {
  final option = find.text('Female');
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

/// Opens one of the two pick lists, types the search it sends as `q`, and takes
/// the row the list answers with.
Future<void> _chooseFromSheet(
  WidgetTester tester, {
  required String tileKey,
  required String search,
  required String option,
}) async {
  final tile = find.byKey(ValueKey(tileKey));
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const ValueKey('option-search')), search);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();

  // The typed search sits in the field above the list, so the same words can
  // be on screen twice; the row is the one inside a list tile.
  await tester.tap(find.widgetWithText(ListTile, option));
  await tester.pumpAndSettle();
}

Future<void> _openVendorService(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('drawer-vendor-service')));
  await tester.pumpAndSettle();
}

Future<void> _openVendorContacts(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('drawer-vendor-contacts')));
  await tester.pumpAndSettle();
}

Future<void> _openVendorImages(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  final row = find.byKey(const ValueKey('drawer-vendor-images'));
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> _openVendorProducts(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  final row = find.byKey(const ValueKey('drawer-vendor-products'));
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> _openVendorAmenities(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  final row = find.byKey(const ValueKey('drawer-vendor-amenities'));
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> _openVendorStory(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  final row = find.byKey(const ValueKey('drawer-vendor-stories'));
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

/// The read answers with a different set per call, so a test can watch what the
/// page shows after a write asked for it again.
Future<void> _stubAmenityGallery(
  WidgetTester tester,
  VendorAmenityGallery gallery,
) async {
  when(
    () =>
        getIt<VendorAmenityRepository>().gallery(locale: any(named: 'locale')),
  ).thenAnswer((_) async => Success(gallery));
}

/// The listing answers page by page, so a paging test replies with the second
/// set once the page asks for it and hands the first page back.
Future<void> _stubProductPages(
  WidgetTester tester, {
  required VendorProductPage firstPage,
  VendorProductPage? secondPage,
}) async {
  when(() => getIt<VendorProductRepository>().products(any())).thenAnswer((
    invocation,
  ) async {
    _productRequests.add(
      invocation.positionalArguments.single as VendorProductQuery,
    );
    final query = _productRequests.last;
    if (query.page > 1) {
      return Success(secondPage ?? _vendorProductsEmpty);
    }
    return Success(firstPage);
  });
}

/// The picture the vendor picks for a service photo.
final _pickedPhoto = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'shop.png',
);

/// A real 1×1 picture, because the product form previews what was picked before
/// it is uploaded and the preview has to decode.
final _pickedPng = AvatarFile(
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
  fileName: 'coffee.png',
);

/// The story the endpoint answers a successful post with, still waiting for an
/// admin.
const _postedStory = VendorStory(
  id: 12,
  type: VendorStoryType.image,
  status: 'pending',
);

/// A clip needs no decoding, since the form only names the file it picked.
final _pickedClip = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'story.mp4',
);

/// The form opens empty for a new line ([editId] null) and filled for the one
/// whose id is given.
Future<void> _openContactForm(WidgetTester tester, {int? editId}) async {
  await tester.tap(
    find.byKey(
      ValueKey(editId == null ? 'contact-add' : 'contact-edit-$editId'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _chooseContactType(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('contact-type-tile')));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, label));
  await tester.pumpAndSettle();
}

Future<void> _fillContactForm(
  WidgetTester tester, {
  required String label,
  required String value,
}) async {
  await _chooseContactType(tester, label);
  await tester.enterText(
    find.byKey(const ValueKey('contact-value-field')),
    value,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('contact-save')));
  await tester.pumpAndSettle();
}

/// The vendor form carries nine fields, so its buttons sit below the fold in a
/// test window; they have to be scrolled to before they can be hit.
Future<void> _scrollAndTap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _fillPasswords(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('current-password-field')),
    'secret1',
  );
  await tester.enterText(
    find.byKey(const ValueKey('new-password-field')),
    'secret2',
  );
  await tester.enterText(
    find.byKey(const ValueKey('confirm-password-field')),
    'secret2',
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const NearbyPlacesParams(latitude: 0, longitude: 0));
    registerFallbackValue(const RandomCategoriesParams(locale: 'en'));
    registerFallbackValue(const CategoryPageParams(locale: 'en'));
    registerFallbackValue(const RandomRegionsParams(locale: 'en'));
    registerFallbackValue(const RegionPageParams(locale: 'en'));
    registerFallbackValue(
      const ServicePageParams(
        scope: ServiceScope.category,
        scopeId: 1,
        locale: 'en',
      ),
    );
    registerFallbackValue(
      const ServiceSearchQuery(text: 'Imran', locale: 'en'),
    );
    registerFallbackValue(const StoryFeedParams(locale: 'en'));
    registerFallbackValue(
      const ServiceStoryFeedParams(serviceId: 1, locale: 'en'),
    );
    registerFallbackValue(const StoryViewParams(storyId: 0, locale: 'en'));
    registerFallbackValue(
      const StoryPollVoteParams(storyId: 0, optionId: 0, locale: 'en'),
    );
    registerFallbackValue(<String>{});
    registerFallbackValue(
      const Credentials(login: '0944444444', password: 'secret1'),
    );
    registerFallbackValue(
      const Registration(
        fullName: 'Imran',
        mobile: '0944444444',
        password: 'secret1',
        gender: AuthGender.male,
      ),
    );
    registerFallbackValue(
      const JoinRequest(
        fullName: 'Imran',
        mobile: '0944444444',
        password: 'secret1',
        gender: AuthGender.male,
        regionId: 1,
        categoryId: 1,
        nameAr: 'الاسد',
        nameEn: 'Asad',
      ),
    );
    registerFallbackValue(
      const ProfileEdit(fullName: 'Imran', gender: AuthGender.male),
    );
    registerFallbackValue(AvatarFile(bytes: Uint8List(0), fileName: 'me.jpg'));
    registerFallbackValue(
      const VendorServiceEdit(nameAr: 'الاسد', nameEn: 'amran'),
    );
    registerFallbackValue(
      const VendorContactEdit(type: 'phone', value: '0999111222'),
    );
    registerFallbackValue(
      const VendorProductEdit(categoryId: 4, nameAr: 'قهوة', price: 1200),
    );
    registerFallbackValue(const VendorProductQuery(locale: 'en'));
    registerFallbackValue(const VendorAmenityEdit(nameAr: 'واي فاي'));
    registerFallbackValue(
      const VendorStoryEdit(type: VendorStoryType.image, captionAr: 'قهوة'),
    );
    registerFallbackValue(
      const PasswordChange(
        currentPassword: 'secret1',
        password: 'secret2',
        confirmation: 'secret2',
      ),
    );
  });

  tearDown(() => resetDependencies());

  testWidgets('shows the animated logo splash before the feed', (tester) async {
    await _pumpSplash(tester);

    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
    expect(find.text('Nearby places'), findsNothing);
  });

  testWidgets('shows onboarding on first launch', (tester) async {
    await _pumpSplash(tester, onboardingCompleted: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Dali Alsham'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Nearby places'), findsNothing);
  });

  testWidgets('skipping onboarding opens the feed', (tester) async {
    await _pumpSplash(tester, onboardingCompleted: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Nearby places'), findsOneWidget);
    verify(() => getIt<OnboardingRepository>().markCompleted()).called(1);
  });

  testWidgets('shows the services feed under the search field', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Nearby places'), findsOneWidget);
    expect(find.text('Discover places around you'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No services here yet'), findsOneWidget);
  });

  testWidgets('drawer holds language and theme controls', (tester) async {
    await _pumpApp(tester);

    expect(find.byIcon(Icons.translate_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-language')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-theme')), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('drawer toggles dark mode and persists it', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    expect(brightness(), Brightness.light);

    await tester.tap(find.byKey(const ValueKey('drawer-theme')));
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.dark);
    verify(() => getIt<ThemeRepository>().saveThemeMode('dark')).called(1);
  });

  testWidgets('drawer switches the app language', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('drawer-language')));
    await tester.pumpAndSettle();

    expect(find.text('الأماكن القريبة'), findsOneWidget);
    verify(() => getIt<LocaleRepository>().saveLocaleCode('ar')).called(1);
  });

  testWidgets('shows the guided tour until it is completed', (tester) async {
    await _pumpApp(tester, tutorialCompleted: false);

    expect(find.byType(FeatureTour), findsOneWidget);
    expect(
      find.text(
        'Tap any circle at the top to preview places full-screen. Watched stories turn grey.',
      ),
      findsOneWidget,
    );

    for (var step = 0; step < 3; step++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(FeatureTour), findsNothing);
    verify(() => getIt<TutorialRepository>().setCompleted(true)).called(1);
  });

  testWidgets('replays the tutorial from the drawer', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('drawer-tutorial')));
    await tester.pumpAndSettle();

    expect(find.byType(FeatureTour), findsOneWidget);
    verify(() => getIt<TutorialRepository>().setCompleted(false)).called(1);
  });

  testWidgets('does not invent ratings for a business profile', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    await _openPlaceProfile(tester, id: place.id);

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.textContaining('out of 5'), findsNothing);
    expect(find.text('Ratings & reviews'), findsNothing);
  });

  testWidgets('shows only listing facts with quick actions', (tester) async {
    const place = Place(
      id: 'node/42',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      address: 'Straight Street',
      phone: '+963 11 000 0001',
      website: 'alkhawali.example',
      openingHours: '12:00–23:30',
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    await _openPlaceProfile(tester, id: place.id);

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.text('Contact & location'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Directions'), findsOneWidget);
    expect(find.text('Visit website'), findsOneWidget);
    expect(find.text('Straight Street'), findsOneWidget);
    expect(find.text('About'), findsNothing);
    expect(find.text('Services & amenities'), findsNothing);
    expect(find.text('Menu'), findsNothing);
  });

  testWidgets('opens the place chat room and sends a message', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    when(
      () => getIt<ChatRepository>().getMessages(
        placeId: any(named: 'placeId'),
        placeName: any(named: 'placeName'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => Success<List<ChatMessage>>([
        ChatMessage(
          id: 'demo/1',
          author: 'Sara',
          text: 'Is Nawfara Cafe open tonight?',
          createdAt: DateTime(2026, 10, 27, 18),
        ),
      ]),
    );
    when(
      () => getIt<ChatRepository>().sendMessage(
        placeId: any(named: 'placeId'),
        text: any(named: 'text'),
      ),
    ).thenAnswer((invocation) async {
      final text = invocation.namedArguments[#text] as String;
      return Success(
        ChatMessage(
          id: 'local/1',
          author: '',
          text: text,
          createdAt: DateTime(2026, 10, 27, 21),
          isMine: true,
        ),
      );
    });

    await _openPlaceProfile(tester, id: place.id);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
    expect(find.text('Chat room'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Is Nawfara Cafe open tonight?'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chat-input')),
      'What time do you close?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pumpAndSettle();

    // The message must leave the composer and appear as a bubble.
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('chat-input')),
    );
    expect(field.controller!.text, isEmpty);
    expect(find.text('What time do you close?'), findsOneWidget);
  });

  testWidgets('opens an empty chat room with no canned messages', (
    tester,
  ) async {
    const place = Place(
      id: 'node/7',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    when(
      () => getIt<ChatRepository>().getMessages(
        placeId: any(named: 'placeId'),
        placeName: any(named: 'placeName'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success<List<ChatMessage>>([]));

    await _openPlaceProfile(tester, id: place.id);
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
    expect(
      find.text('No messages yet — start the conversation.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Messages stay on this device only — chat is not connected yet.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('opens the place story from its profile', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    await _openPlaceProfile(tester, id: place.id);
    await tester.tap(find.text('Watch story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(StoriesPage);
    expect(viewer, findsOneWidget);
    expect(
      find.descendant(of: viewer, matching: find.text('Nawfara Cafe')),
      findsWidgets,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(StoriesPage), findsNothing);
  });

  testWidgets('profile avatar chooses between photo and story', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    await _openPlaceProfile(tester, id: place.id);

    await tester.tap(find.byKey(const ValueKey('profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Show photo'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Watch story'), findsOneWidget);

    await tester.tap(find.text('Show photo'));
    await tester.pumpAndSettle();
    final photo = find.byKey(const ValueKey('profile-photo'));
    expect(photo, findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-photo-close')));
    await tester.pumpAndSettle();
    expect(photo, findsNothing);

    await tester.tap(find.byKey(const ValueKey('profile-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Watch story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StoriesPage), findsOneWidget);
  });

  testWidgets('shows live banners as the hero under the search field', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );
    // Without banners the bar collapses and leaves no trace in the feed.
    expect(find.text('Ad'), findsNothing);

    when(() => getIt<GetBanners>().call(any())).thenAnswer(
      (_) async => const Success<List<BannerAd>>([
        BannerAd(id: 1, text: '20% discount with Banque Saudi Fransi (BSF)'),
        BannerAd(id: 2, text: 'Free delivery across Damascus this week'),
      ]),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    final ads = find.byType(AdvertiseBar);
    expect(ads, findsOneWidget);
    expect(
      find.text('20% discount with Banque Saudi Fransi (BSF)'),
      findsOneWidget,
    );
    expect(find.text('Ad'), findsOneWidget);
    expect(
      tester.getTopLeft(ads).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.byType(TextField)).dy,
      ),
    );
    expect(
      tester.getBottomLeft(ads).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(PlaceStoriesBar)).dy),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('ad-dot-0'))).width,
      greaterThan(tester.getSize(find.byKey(const ValueKey('ad-dot-1'))).width),
    );

    await tester.pump(AdvertiseBar.autoAdvance);
    await tester.pumpAndSettle();

    expect(
      find.text('Free delivery across Damascus this week'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('ad-dot-1'))).width,
      greaterThan(tester.getSize(find.byKey(const ValueKey('ad-dot-0'))).width),
    );
  });

  testWidgets('shows shimmer placeholders while banners reload', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );
    expect(find.byType(ShimmerBox), findsNothing);

    final pending = Completer<Result<List<BannerAd>>>();
    when(
      () => getIt<GetBanners>().call(any()),
    ).thenAnswer((_) => pending.future);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShimmerBox), findsWidgets);

    pending.complete(
      const Success<List<BannerAd>>([
        BannerAd(id: 1, text: '20% discount with Banque Saudi Fransi (BSF)'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShimmerBox), findsNothing);
    expect(
      find.text('20% discount with Banque Saudi Fransi (BSF)'),
      findsOneWidget,
    );
  });

  testWidgets('shows nearby places as stories under the hero banner', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    final stories = find.byType(PlaceStoriesBar);
    expect(stories, findsOneWidget);
    expect(
      find.descendant(of: stories, matching: find.text('Stories')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stories, matching: find.text('Nawfara Cafe')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(stories).dy,
      greaterThan(tester.getCenter(find.byType(TextField)).dy),
    );
  });

  testWidgets('stories open and auto-advance to the next place', (
    tester,
  ) async {
    const first = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );
    const second = Place(
      id: 'node/2',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.512,
      longitude: 36.292,
      distanceMeters: 260,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [first, second])),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(PlaceStoriesBar),
        matching: find.text('Nawfara Cafe'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(StoriesPage);
    expect(viewer, findsOneWidget);
    expect(
      find.descendant(of: viewer, matching: find.text('Nawfara Cafe')),
      findsWidgets,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(of: viewer, matching: find.text('Al Khawali Restaurant')),
      findsWidgets,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(StoriesPage), findsNothing);
  });

  testWidgets('watched stories turn their ring grey', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    final ring = find.byKey(const ValueKey('story-ring-node/1'));
    BoxDecoration ringDecoration() =>
        tester.widget<Container>(ring).decoration! as BoxDecoration;

    expect(ringDecoration().color, const Color(0xFF00B843));

    await tester.tap(
      find.descendant(
        of: find.byType(PlaceStoriesBar),
        matching: find.text('Nawfara Cafe'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(ringDecoration().color, const Color(0xFFBDBDBD));
  });

  testWidgets('the stories the services posted take over the strip', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);

    final strip = find.byType(StoryStrip);
    expect(strip, findsOneWidget);
    expect(
      find.byType(PlaceStoriesBar),
      findsNothing,
      reason: 'a story that exists replaces the stand-in',
    );
    expect(
      find.descendant(of: strip, matching: find.text('الاسد')),
      findsNWidgets(3),
    );
    // Each card says which of the three kinds it is.
    for (final label in const ['Poll', 'Video', 'Photo']) {
      expect(
        find.descendant(of: strip, matching: find.text(label)),
        findsOneWidget,
        reason: label,
      );
    }

    BoxDecoration ringDecoration() =>
        tester.widget<Container>(find.byKey(const ValueKey('story-ring-5')))
            .decoration! as BoxDecoration;
    expect(ringDecoration().color, const Color(0xFF00B843));
  });

  testWidgets('pulling the feed reads the stories again', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    // Whatever the strip was asked for on the way in.
    verify(() => getIt<GetStoryFeed>().call(captureAny()));

    // The next page the strip is answered with names a story it has not shown.
    when(
      () => getIt<GetStoryFeed>().call(any()),
    ).thenAnswer((_) async => const Success(
      StoryFeed(
        stories: [
          Story(
            id: 77,
            type: StoryType.image,
            imageUrl: 'https://dalildimashq.com/storage/stories/77.png',
            caption: 'عرض جديد اليوم',
            service: StoryService(id: 1, name: 'الاسد'),
          ),
        ],
        hasMore: false,
      ),
    ));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pump();
    await tester.pumpAndSettle();

    // The pull asks once more, in the language on screen, and the strip takes
    // the story that came with it: the section with new data is the one that
    // rebuilds.
    final asked = verify(
      () => getIt<GetStoryFeed>().call(captureAny()),
    ).captured.cast<StoryFeedParams>();
    expect(asked, hasLength(1));
    expect(asked.single.locale, 'en');
    expect(find.byKey(const ValueKey('story-card-77')), findsOneWidget);
    expect(find.byKey(const ValueKey('story-card-5')), findsNothing);
  });

  testWidgets('a refresh leaves the sections that have no new rows', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      stories: _serviceStories,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    // The header button asks for the same whole page a pull does. A tall window
    // keeps every section laid out, so the rows watched here can only vanish for
    // a reason of their own.
    _showWholeFeed(tester);

    // Each listing answers with the rows the sections already show. The rails
    // need rows of their own: a section with nothing on it yet rightly shows its
    // placeholders, and those are a different section's answer, not a loss.
    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      return Success(
        ServicePage(services: _keptRows(params), hasMore: false),
      );
    });
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    final rows = find.byType(ServiceCard).evaluate().length;
    expect(rows, greaterThan(0));
    // The stories are read again on every trip, so what the strip asks for is
    // the proof that the refresh ran and was not a no-op.
    verify(() => getIt<GetStoryFeed>().call(any()));

    // Every listing is on its way and none of it has arrived.
    final onItsWay = Completer<void>();
    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      await onItsWay.future;
      return Success(
        ServicePage(services: _keptRows(params), hasMore: false),
      );
    });

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    verify(() => getIt<GetStoryFeed>().call(any())).called(1);

    // A section is rebuilt when its own rows change, not because a refresh was
    // asked for, so nothing on screen blanks while the pages are away.
    expect(find.byType(ServiceCard), findsNWidgets(rows));
    expect(find.byKey(const ValueKey('story-card-5')), findsOneWidget);

    onItsWay.complete();
    await tester.pump();
    await tester.pumpAndSettle();
    // The same rows came back, so the list is still the one it was.
    expect(find.byType(ServiceCard), findsNWidgets(rows));
    expect(find.byKey(const ValueKey('story-card-5')), findsOneWidget);
  });

  testWidgets('the stories row holds placeholders, then an empty row holds nothing', (
    tester,
  ) async {
    // The strip on its own: the shimmer runs forever, so the app cannot be
    // pumped to settle while it is on screen.
    Future<void> pumpStrip(StoryFeedStatus status, List<Story> stories) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StoryStrip(
              status: status,
              stories: stories,
              viewedIds: const {},
              onStoryTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpStrip(StoryFeedStatus.loading, const []);
    expect(find.byType(ShimmerBox), findsNWidgets(5));
    expect(find.text('Stories'), findsNothing);

    await pumpStrip(StoryFeedStatus.failure, const []);
    expect(find.byType(ShimmerBox), findsNothing);
    expect(find.text('Stories'), findsNothing);

    await pumpStrip(StoryFeedStatus.ready, const []);
    expect(find.text('Stories'), findsNothing);

    await pumpStrip(StoryFeedStatus.ready, _serviceStories);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.byKey(const ValueKey('story-card-5')), findsOneWidget);
  });

  testWidgets('a poll slide asks the question and weighs every answer', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(viewer, findsOneWidget);
    for (final text in ['ما هو طبقك المفضل؟', 'شاورما', 'فلافل', '70%', '30%']) {
      expect(
        find.descendant(of: viewer, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceStoriesPage), findsNothing);
  });

  testWidgets('a clip is named on its slide and the bar runs to the next story', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('Poll')),
      findsOneWidget,
    );

    // The five seconds of the question are up, so the clip is on screen. The
    // slide runs 260 ms and the story it lands on is drawn on the frame after.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: viewer, matching: find.text('Video')),
      findsOneWidget,
    );

    // The clip cannot open here, and its handback never comes either; the bar
    // still runs the slide's own five seconds and carries the reader on.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: viewer, matching: find.text('Photo')),
      findsOneWidget,
    );
  });

  testWidgets('a clip that opens lands on the slide it opened for', (
    tester,
  ) async {
    // A test machine has no decoder, so the page is handed a platform that
    // answers the way a phone does: late, after the slide is already drawn.
    final previous = VideoPlayerPlatform.instance;
    final platform = _AnswersForClips();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() {
      VideoPlayerPlatform.instance = previous;
      platform._events.close();
    });

    await _pumpApp(tester, stories: _serviceStories);
    await tester.tap(find.byKey(const ValueKey('story-card-3')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('Video')),
      findsOneWidget,
    );
    // The decoder has not answered yet, so the slide holds its poster.
    expect(find.byKey(const ValueKey('clip-on-screen')), findsNothing);

    // The answer arrives after the slide was drawn, and the page looks again
    // to put the clip over the poster it was standing in for.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('clip-on-screen')), findsOneWidget);

    // The bar now keeps the clip's eight seconds, not the picture's five.
    await tester.pump(const Duration(seconds: 5));
    expect(
      find.descendant(of: viewer, matching: find.text('Video')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceStoriesPage), findsNothing);
  });

  testWidgets('the last story hands the reader back to the feed', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);

    await tester.tap(find.byKey(const ValueKey('story-card-2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ServiceStoriesPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceStoriesPage), findsNothing);
    expect(find.byType(StoryStrip), findsOneWidget);
  });

  testWidgets('a watched service story greys its ring', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);

    BoxDecoration ringDecoration() =>
        tester.widget<Container>(find.byKey(const ValueKey('story-ring-3')))
            .decoration! as BoxDecoration;
    expect(ringDecoration().color, const Color(0xFF00B843));

    await tester.tap(find.byKey(const ValueKey('story-card-3')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(ringDecoration().color, const Color(0xFFBDBDBD));
  });

  testWidgets('a signed-in reader is offered the answers, not the counts', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories, token: 't-900');

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('Tap an answer to vote')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: viewer,
        matching: find.byIcon(Icons.radio_button_unchecked_rounded),
      ),
      findsNWidgets(2),
    );
    // The tally stays hidden until the answer is given.
    expect(
      find.descendant(of: viewer, matching: find.text('70%')),
      findsNothing,
    );
    expect(
      find.descendant(of: viewer, matching: find.text('30%')),
      findsNothing,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('an answer is posted once and the slide redraws with the tally', (
    tester,
  ) async {
    final sent = <StoryPollVoteParams>[];
    await _pumpApp(tester, stories: _serviceStories, token: 't-900');
    when(
      () => getIt<VoteStoryPoll>().call(any()),
    ).thenAnswer((invocation) async {
      sent.add(
        invocation.positionalArguments.single as StoryPollVoteParams,
      );
      return const Success('Vote recorded');
    });

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    await tester.tap(find.byKey(const ValueKey('story-poll-option-5')));
    await tester.pump();

    expect(sent, hasLength(1));
    expect(sent.single.storyId, 5);
    expect(sent.single.optionId, 5);
    expect(sent.single.locale, 'en');

    // The reader's own answer is marked, and its share is the one that grew.
    expect(
      find.descendant(of: viewer, matching: find.byIcon(Icons.check_rounded)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: viewer, matching: find.text('64%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: viewer, matching: find.text('36%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: viewer, matching: find.text('11')),
      findsOneWidget,
      reason: 'the total moved with the vote',
    );

    // A second answer on a poll already answered is not asked for.
    await tester.tap(find.byKey(const ValueKey('story-poll-option-4')));
    await tester.pump();
    expect(sent, hasLength(1));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a vote the server refuses leaves the tally and says so', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories, token: 't-900');
    when(
      () => getIt<VoteStoryPoll>().call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    await tester.tap(find.byKey(const ValueKey('story-poll-option-5')));
    await tester.pump();
    await tester.pump();

    expect(
      find.descendant(of: viewer, matching: find.text('Tap an answer to vote')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: viewer,
        matching: find.byIcon(Icons.radio_button_unchecked_rounded),
      ),
      findsNWidgets(2),
      reason: 'no answer was taken, so nothing is marked',
    );
    expect(
      find.descendant(
        of: viewer,
        matching: find.text('Your vote could not be recorded'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('the viewer tells the server about a story once a visit', (
    tester,
  ) async {
    final seen = <int>[];
    await _pumpApp(tester, stories: _serviceStories, token: 't-900');
    when(
      () => getIt<RecordStoryView>().call(any()),
    ).thenAnswer((invocation) async {
      seen.add(
        (invocation.positionalArguments.single as StoryViewParams).storyId,
      );
      return const Success('View recorded');
    });

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(seen, [5]);

    // The question's five seconds are up, so the reader is carried on.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(seen, [5, 3]);

    // Back to the question, which this visit already told the server about.
    await tester.tapAt(const Offset(10, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(seen, [5, 3], reason: 'a story is said once a visit');

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a reader who is not signed in says nothing about a story', (
    tester,
  ) async {
    var calls = 0;
    await _pumpApp(tester, stories: _serviceStories);
    when(
      () => getIt<RecordStoryView>().call(any()),
    ).thenAnswer((_) async {
      calls++;
      return const Success('View recorded');
    });

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    expect(calls, 0);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a tap runs the whole set the service posted', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    _stubArchivePages([_serviceWholeSet]);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final asked = verify(
      () => getIt<GetServiceStoryFeed>().call(captureAny()),
    ).captured.single as ServiceStoryFeedParams;
    expect(asked.serviceId, 1);
    expect(asked.locale, 'en');
    expect(asked.page, 1);

    // The story tapped is the one on screen.
    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('ما هو طبقك المفضل؟')),
      findsOneWidget,
    );

    // and it runs past the page the strip showed: this question belongs to a
    // story the strip never handed over.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: viewer, matching: find.text('متى تزورنا؟')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a tap follows every page the archive offers', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    _stubArchivePages([_serviceWholeSet, _serviceWholeSetNextPage]);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final pages = verify(
      () => getIt<GetServiceStoryFeed>().call(captureAny()),
    ).captured.cast<ServiceStoryFeedParams>().map((params) => params.page);
    expect(pages, [1, 2]);

    // 5, 4, 3 and 2 from the first page, then the one the second brought.
    final viewer = find.byType(ServiceStoriesPage);
    for (var slide = 0; slide < 4; slide++) {
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      find.descendant(of: viewer, matching: find.text('خصم على القائمة')),
      findsWidgets,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a tap stops gathering when the pages run long', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    // Every page offers another, so it is the walk that ends, not the server.
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as ServiceStoryFeedParams;
      return Success(
        StoryFeed(
          stories: [
            Story(
              id: 100 + params.page,
              type: StoryType.image,
              caption: 'عرض جديد اليوم',
              service: const StoryService(id: 1, name: 'الاسد'),
            ),
          ],
          hasMore: true,
          nextPage: params.page + 1,
        ),
      );
    });

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final pages = verify(
      () => getIt<GetServiceStoryFeed>().call(captureAny()),
    ).captured.cast<ServiceStoryFeedParams>().map((params) => params.page);
    expect(pages, [1, 2, 3]);
    expect(find.byType(ServiceStoriesPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('an archive that will not answer leaves the strip to play', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer(
      (_) async => const FailureResult(ServerFailure('HTTP 500')),
    );

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(viewer, findsOneWidget);
    expect(find.byType(ServiceStoryListPage), findsNothing);
    // The strip's own set: the clip is the story that follows, as it was
    // before the tap ever asked for anything.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: viewer, matching: find.text('Video')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a tap opens where the reader pointed even if the archive moved', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);
    // The archive dropped the story the strip still shows; the reader's own
    // pick stays at the head of the set.
    _stubArchivePages([[_serviceArchive[1], _serviceArchive[2]]]);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('ما هو طبقك المفضل؟')),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: viewer, matching: find.text('متى تزورنا؟')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a second tap while the first waits opens one viewer', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);
    final onItsWay = Completer<Result<StoryFeed>>();
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer((_) => onItsWay.future);

    await tester.tap(find.byKey(const ValueKey('story-card-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('story-card-3')));
    await tester.pump();

    onItsWay.complete(
      Success(StoryFeed(stories: _serviceWholeSet, hasMore: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(ServiceStoriesPage);
    expect(viewer, findsOneWidget);
    // The story first asked for is the one on screen.
    expect(
      find.descendant(of: viewer, matching: find.text('ما هو طبقك المفضل؟')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a story that names no service asks for no archive', (
    tester,
  ) async {
    await _pumpApp(tester, stories: const [
      Story(id: 9, type: StoryType.image, imageUrl: 'https://x/y.png'),
    ]);

    await tester.tap(find.byKey(const ValueKey('story-card-9')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    verifyNever(() => getIt<GetServiceStoryFeed>().call(any()));
    expect(find.byType(ServiceStoriesPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('the service on a story opens the archive behind it', (
    tester,
  ) async {
    final asked = <ServiceStoryFeedParams>[];
    await _pumpApp(tester, stories: _serviceStories);
    await _openServiceViewer(tester);

    // The archive is asked for from the viewer's service row, where the reader
    // is standing on one of the service's stories.
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer((invocation) async {
      asked.add(
        invocation.positionalArguments.single as ServiceStoryFeedParams,
      );
      return Success(StoryFeed(stories: _serviceArchive, hasMore: false));
    });

    await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(asked.single.serviceId, 1);
    expect(asked.single.locale, 'en');
    expect(asked.single.page, 1);

    final list = find.byType(ServiceStoryListPage);
    expect(list, findsOneWidget);
    // The archive is named for the service the reader was watching.
    expect(
      find.descendant(of: list, matching: find.text('الاسد')),
      findsOneWidget,
    );
    for (final story in _serviceArchive) {
      expect(
        find.byKey(ValueKey('service-story-row-${story.id}')),
        findsOneWidget,
      );
    }
    // Newest first, each row saying what it is and how long it stays.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('service-story-row-6'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('service-story-row-4')))
            .dy,
      ),
    );
    expect(
      find.descendant(of: list, matching: find.text('Gone in 23 h')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: list, matching: find.text('Poll')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: list, matching: find.text('Video')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: list, matching: find.text('Photo')),
      findsOneWidget,
    );
  });

  testWidgets('the viewer names the whole set as a control of its own', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);

    await _openServiceViewer(tester);

    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('See all')),
      findsOneWidget,
    );

    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer(
      (_) async => Success(StoryFeed(stories: _serviceArchive, hasMore: false)),
    );

    await tester.tap(find.byKey(const ValueKey('story-open-service-all-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The archive, not the one page the strip handed over.
    expect(find.byType(ServiceStoryListPage), findsOneWidget);
    expect(find.byKey(const ValueKey('service-story-row-6')), findsOneWidget);
    expect(find.byKey(const ValueKey('service-story-row-2')), findsOneWidget);
  });

  testWidgets('the archive holds placeholders while its page is on the way', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);
    await _openServiceViewer(tester);

    final onItsWay = Completer<Result<StoryFeed>>();
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer((_) => onItsWay.future);

    await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The shimmer runs forever, so the page is settled by hand.
    final list = find.byType(ServiceStoryListPage);
    expect(
      find.descendant(of: list, matching: find.byType(ShimmerBox)),
      findsNWidgets(5),
    );
    expect(find.byKey(const ValueKey('service-story-row-6')), findsNothing);

    onItsWay.complete(
      Success(StoryFeed(stories: _serviceArchive, hasMore: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(of: list, matching: find.byType(ShimmerBox)),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('service-story-row-6')), findsOneWidget);
  });

  testWidgets('a story in the archive opens the viewer at that story', (
    tester,
  ) async {
    await _pumpApp(tester, stories: _serviceStories);
    await _openServiceViewer(tester);
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer(
      (_) async => Success(StoryFeed(stories: _serviceArchive, hasMore: false)),
    );

    await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const ValueKey('service-story-row-4')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));

    // The question of the story tapped, not the one the strip started with.
    final viewer = find.byType(ServiceStoriesPage);
    expect(
      find.descendant(of: viewer, matching: find.text('متى تزورنا؟')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: viewer, matching: find.text('ما هو طبقك المفضل؟')),
      findsNothing,
    );
  });

  testWidgets('the archive offers the page that follows', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    await _openServiceViewer(tester);
    _stubArchivePages([
      [_serviceArchive[0]],
      _serviceWholeSetNextPage,
    ]);

    await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final list = find.byType(ServiceStoryListPage);
    expect(find.byKey(const ValueKey('service-stories-more')), findsOneWidget);
    expect(find.byKey(const ValueKey('service-story-row-2')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('service-stories-more')));
    await tester.pump();
    await tester.pump();

    final second = verify(
      () => getIt<GetServiceStoryFeed>().call(captureAny()),
    ).captured.last as ServiceStoryFeedParams;
    expect(second.page, 2);
    // The older story joins the list instead of replacing it.
    expect(find.byKey(const ValueKey('service-story-row-6')), findsOneWidget);
    expect(find.byKey(const ValueKey('service-story-row-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('service-stories-more')), findsNothing);
    expect(
      find.descendant(of: list, matching: find.text('Gone in 8 h')),
      findsOneWidget,
    );
  });

  testWidgets('a service with nothing on its stories says so', (tester) async {
    await _pumpApp(tester, stories: _serviceStories);
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer(
      (_) async => Success(StoryFeed(stories: const [], hasMore: false)),
    );

    await _openServiceArchive(tester);

    final list = find.byType(ServiceStoryListPage);
    expect(
      find.descendant(
        of: list,
        matching: find.text('This service has no stories right now'),
      ),
      findsOneWidget,
    );
    for (final story in _serviceArchive) {
      expect(
        find.byKey(ValueKey('service-story-row-${story.id}')),
        findsNothing,
      );
    }
  });

  testWidgets('an archive that will not load is retried from the page', (
    tester,
  ) async {
    var calls = 0;
    await _pumpApp(tester, stories: _serviceStories);
    await _openServiceViewer(tester);
    when(
      () => getIt<GetServiceStoryFeed>().call(any()),
    ).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? const FailureResult(ServerFailure('HTTP 500'))
          : Success(StoryFeed(stories: _serviceArchive, hasMore: false));
    });

    await tester.tap(find.byKey(const ValueKey('story-open-service-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final list = find.byType(ServiceStoryListPage);
    expect(
      find.descendant(
        of: list,
        matching: find.text('Something went wrong while loading places'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('service-story-row-6')), findsNothing);

    await tester.tap(find.descendant(of: list, matching: find.text('Retry')));
    await tester.pump();
    await tester.pump();

    expect(calls, 2);
    expect(find.byKey(const ValueKey('service-story-row-6')), findsOneWidget);
    expect(find.descendant(of: list, matching: find.text('Retry')), findsNothing);
  });

  testWidgets('a story of a service nobody names is not an entry point', (
    tester,
  ) async {
    await _pumpApp(tester, stories: const [
      Story(id: 9, type: StoryType.image, imageUrl: 'https://x/y.png'),
    ]);

    await tester.tap(find.byKey(const ValueKey('story-card-9')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Nothing to open: the story does not say who posted it.
    expect(find.byKey(const ValueKey('story-open-service-1')), findsNothing);
    expect(
      find.byKey(const ValueKey('story-open-service-all-1')),
      findsNothing,
    );
    expect(find.byType(ServiceStoryListPage), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('lists the nearest services under the search field', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    await _stubFeed(tester);

    final cards = find.byType(ServiceCard);
    expect(cards, findsNWidgets(2));
    expect(
      find.descendant(of: cards, matching: find.text('Nawfara Cafe')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: cards, matching: find.text('400 m')),
      findsOneWidget,
    );

    final request = _lastServicePageRequestOf(ServiceScope.nearby);
    expect(request.userLat, 33.51);
    expect(request.userLng, 36.29);
    // A listing with no page after it does not offer to load one.
    expect(find.byKey(const ValueKey('feed-load-more')), findsNothing);
  });

  testWidgets('the load more row appends the next nearby page', (tester) async {
    await _pumpApp(tester);
    // The row sits under the two cards of the first page, so it needs a window
    // tall enough for the feed to build it.
    _showWholeFeed(tester);
    await _stubFeed(
      tester,
      secondPage: const [
        ServiceSummary(
          id: 7,
          name: 'Al Sham Pharmacy',
          categoryName: 'Pharmacies',
        ),
      ],
    );

    expect(find.byType(ServiceCard), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('feed-load-more')));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceCard), findsNWidgets(3));
    expect(
      find.descendant(
        of: find.byType(ServiceCard),
        matching: find.text('Al Sham Pharmacy'),
      ),
      findsOneWidget,
    );
    expect(_lastServicePageRequestOf(ServiceScope.nearby).page, 2);
    expect(find.byKey(const ValueKey('feed-load-more')), findsNothing);
  });

  testWidgets('a feed that failed asks to retry and fills when it works', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    await _stubFeed(tester, failure: const ServerFailure());

    expect(
      find.text('Something went wrong while loading services'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('feed-retry')), findsOneWidget);

    await _stubFeed(tester);

    expect(find.byType(ServiceCard), findsNWidgets(2));
    expect(
      find.text('Something went wrong while loading services'),
      findsNothing,
    );
  });

  testWidgets('an empty listing says the city has nothing yet', (tester) async {
    await _pumpApp(tester);
    await _stubFeed(tester, firstPage: const []);

    expect(find.text('No services here yet'), findsOneWidget);
  });

  testWidgets('search waits for a pause in typing before filtering', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    await _stubFeed(tester);
    expect(find.byType(ServiceCard), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'Nawfara');
    await tester.pump();
    expect(find.byType(ServiceCard), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceCard), findsOneWidget);
  });

  testWidgets('typing narrows the feed by category and region too', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    await _stubFeed(tester);
    final cards = find.byType(ServiceCard);

    await tester.enterText(find.byType(TextField), 'baker');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(cards, findsOneWidget);
    expect(
      find.descendant(of: cards, matching: find.text('Al Baraka Bakery')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Barzeh');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(cards, findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nothing here');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(cards, findsNothing);
    expect(find.text('Nothing matched that search'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('search-clear-feed')));
    await tester.pumpAndSettle();
    expect(cards, findsNWidgets(2));
  });

  testWidgets('shows random categories and opens the full list', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomCategories>().call(any())).thenAnswer(
      (_) async => const Success<List<ExploreCategory>>([
        ExploreCategory(
          id: 1,
          name: 'Restaurants',
          tagline: 'Discover the most delicious dishes',
        ),
      ]),
    );
    when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
      (_) async => const Success(
        CategoryPage(
          categories: [
            ExploreCategory(
              id: 1,
              name: 'Restaurants',
              tagline: 'Discover the most delicious dishes',
            ),
            ExploreCategory(
              id: 2,
              name: 'Cafés',
              tagline: 'Fresh coffee around the corner',
            ),
          ],
          hasMore: true,
          nextPage: 2,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Main categories'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CategoryPills),
        matching: find.text('Restaurants'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('categories-see-all')));
    await tester.pumpAndSettle();

    final page = find.byType(CategoriesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(
        of: page,
        matching: find.text('Fresh coffee around the corner'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Load more')),
      findsOneWidget,
    );
  });

  testWidgets('shows random regions and opens the full list', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomRegions>().call(any())).thenAnswer(
      (_) async => const Success<List<Region>>([
        Region(
          id: 1,
          name: 'Mazzeh',
          welcomePhrase: 'Welcome to Mazzeh',
          servicesCount: 4,
        ),
      ]),
    );
    when(() => getIt<GetRegionPage>().call(any())).thenAnswer(
      (_) async => const Success(
        RegionPage(
          regions: [
            Region(
              id: 1,
              name: 'Mazzeh',
              welcomePhrase: 'Welcome to Mazzeh',
              servicesCount: 4,
            ),
            Region(id: 2, name: 'Dummer', welcomePhrase: 'Welcome to Dummer'),
          ],
          hasMore: true,
          nextPage: 2,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Explore regions'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(RegionRail), matching: find.text('Mazzeh')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(RegionRail),
        matching: find.text('(4+)'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(RegionRail),
        matching: find.text('See all'),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(RegionsPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Dummer')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Load more')),
      findsOneWidget,
    );
  });

  testWidgets('opens the services of a category', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomCategories>().call(any())).thenAnswer(
      (_) async => const Success<List<ExploreCategory>>([
        ExploreCategory(id: 1, name: 'Shawarma Streets'),
      ]),
    );
    when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
      (_) async => const Success(
        CategoryPage(
          categories: [ExploreCategory(id: 1, name: 'Shawarma Streets')],
          hasMore: false,
        ),
      ),
    );
    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 2,
              name: 'Imran',
              regionName: 'Mazzeh',
              address: 'Damascus',
              rating: 4.5,
              reviewsCount: 7,
              distanceText: '400 m',
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    // The home pills only narrow the list under the search field; the whole
    // section, with the page of its services, is one press further away.
    await tester.tap(find.byKey(const ValueKey('categories-see-all')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(CategoriesPage),
        matching: find.text('Shawarma Streets'),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(ServicesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Imran')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Mazzeh')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('400 m')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('(7)')),
      findsOneWidget,
    );

    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.category);
    expect(params.scopeId, 1);
    expect(params.userLat, 33.51);
    expect(params.userLng, 36.29);
  });

  testWidgets('a category pill fills the list with that category', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    _showWholeFeed(tester);
    _stubCategories(const [
      ExploreCategory(id: 1, name: 'Cafés'),
      ExploreCategory(id: 2, name: 'Bakeries'),
    ]);
    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      return switch (params.scope) {
        ServiceScope.category => const Success(
          ServicePage(
            services: [ServiceSummary(id: 77, name: 'Sweets Corner')],
            hasMore: false,
          ),
        ),
        ServiceScope.nearby => const Success(
          ServicePage(services: _feedServices, hasMore: false),
        ),
        _ => const Success(ServicePage(services: [], hasMore: false)),
      };
    });

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    // Only the list under the pills changes; the rails above keep their own.
    final cards = find.byType(ServiceCard);
    expect(
      find.descendant(of: cards, matching: find.text('Nawfara Cafe')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('category-pill-2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: cards, matching: find.text('Sweets Corner')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: cards, matching: find.text('Nawfara Cafe')),
      findsNothing,
    );

    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.category);
    expect(params.scopeId, 2);
    expect(params.userLat, 33.51);
  });

  testWidgets('the all pill hands the list back to everything nearby', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubCategories(const [ExploreCategory(id: 1, name: 'Cafés')]);
    await _stubFeed(tester);

    await tester.tap(find.byKey(const ValueKey('category-pill-1')));
    await tester.pumpAndSettle();
    expect(find.text('No services here yet'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-pill-all')));
    await tester.pumpAndSettle();

    expect(find.text('No services here yet'), findsNothing);
    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.nearby);
    expect(params.scopeId, isNull);
  });

  testWidgets('the same pill pressed again lifts its filter', (tester) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubCategories(const [ExploreCategory(id: 1, name: 'Cafés')]);
    await _stubFeed(tester);

    await tester.tap(find.byKey(const ValueKey('category-pill-1')));
    await tester.pumpAndSettle();
    expect(_lastServicePageRequest().scope, ServiceScope.category);

    await tester.tap(find.byKey(const ValueKey('category-pill-1')));
    await tester.pumpAndSettle();

    expect(_lastServicePageRequest().scope, ServiceScope.nearby);
    expect(_pillIsChosen(tester, 'category-pill-all'), isTrue);
  });

  testWidgets('only the pressed pill is drawn as chosen', (tester) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubCategories(const [
      ExploreCategory(id: 1, name: 'Cafés'),
      ExploreCategory(id: 2, name: 'Bakeries'),
    ]);
    await _stubFeed(tester);

    expect(_pillIsChosen(tester, 'category-pill-all'), isTrue);
    expect(_pillIsChosen(tester, 'category-pill-1'), isFalse);

    await tester.tap(find.byKey(const ValueKey('category-pill-1')));
    await tester.pumpAndSettle();

    expect(_pillIsChosen(tester, 'category-pill-all'), isFalse);
    expect(_pillIsChosen(tester, 'category-pill-1'), isTrue);
    expect(find.byType(CategoryPills), findsOneWidget);
  });

  testWidgets('a pill that left the showcase falls back to all', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubCategories(const [
      ExploreCategory(id: 1, name: 'Cafés'),
      ExploreCategory(id: 2, name: 'Bakeries'),
    ]);
    await _stubFeed(tester);

    await tester.tap(find.byKey(const ValueKey('category-pill-2')));
    await tester.pumpAndSettle();

    _stubCategories(const [ExploreCategory(id: 3, name: 'Pharmacies')]);
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('category-pill-2')), findsNothing);
    expect(find.byKey(const ValueKey('category-pill-3')), findsOneWidget);
    expect(_pillIsChosen(tester, 'category-pill-all'), isTrue);
    expect(_lastServicePageRequest().scope, ServiceScope.nearby);
  });

  testWidgets('the header city button narrows the list to one region', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    _showWholeFeed(tester);
    _stubRegionFeed();

    await tester.tap(find.byKey(const ValueKey('header-city')));
    await tester.pumpAndSettle();
    await tester.tap(_sheetOption('المزة'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('المزة'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ServiceCard),
        matching: find.text('Mazzeh Grill'),
      ),
      findsOneWidget,
    );

    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.region);
    expect(params.scopeId, 1);
    expect(params.userLat, 33.51);
  });

  testWidgets('the same region picked again gives the list back', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubRegionFeed();

    await tester.tap(find.byKey(const ValueKey('header-city')));
    await tester.pumpAndSettle();
    await tester.tap(_sheetOption('ابن العماد'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('header-city')));
    await tester.pumpAndSettle();
    await tester.tap(_sheetOption('ابن العماد'));
    await tester.pumpAndSettle();

    // One press narrows the list to the region, the next takes it away again.
    final requests = _servicePageRequests.toList();
    expect(requests[requests.length - 2].scope, ServiceScope.region);
    expect(requests.last.scope, ServiceScope.nearby);
    expect(requests.last.scopeId, isNull);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Damascus')),
      findsOneWidget,
    );
  });

  testWidgets('a region and a category never narrow the list together', (
    tester,
  ) async {
    await _pumpApp(tester);
    _showWholeFeed(tester);
    _stubCategories(const [ExploreCategory(id: 1, name: 'Cafés')]);
    _stubRegionFeed();
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('category-pill-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('header-city')));
    await tester.pumpAndSettle();
    await tester.tap(_sheetOption('المزة'));
    await tester.pumpAndSettle();

    final requests = _servicePageRequests.toList();
    expect(requests[requests.length - 2].scope, ServiceScope.category);
    expect(requests[requests.length - 2].scopeId, 1);
    expect(requests.last.scope, ServiceScope.region);
    expect(requests.last.scopeId, 1);
    expect(
      tester.widget<CategoryPills>(find.byType(CategoryPills)).selectedId,
      isNull,
    );
  });

  testWidgets('the bell says there is nothing to read yet', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('header-notifications')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Nothing new right now'), findsOneWidget);
  });

  testWidgets('the button beside the field opens the filtered search', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('feed-filters')));
    await tester.pumpAndSettle();

    expect(find.byType(ServicesSearchPage), findsOneWidget);
  });

  testWidgets('the bar under the feed holds the five destinations', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.byType(AppBottomBar), findsOneWidget);
    for (final key in [
      'nav-home',
      'nav-categories',
      'nav-menu',
      'nav-favorites',
      'nav-account',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
  });

  testWidgets('the mark in the middle of the bar slides the drawer open', (
    tester,
  ) async {
    await _pumpApp(tester);

    // The mark rises above the bar; its top must be tappable too.
    final mark = tester.getRect(find.byKey(const ValueKey('nav-menu')));
    await tester.tapAt(mark.topCenter + const Offset(0, 6));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-language')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-theme')), findsOneWidget);
  });

  testWidgets('the bar walks to the sections it names', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('nav-categories')));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-favorites')));
    await tester.pumpAndSettle();
    expect(find.byType(ServicesPage), findsOneWidget);
    expect(_lastServicePageRequest().scope, ServiceScope.favorites);
  });

  testWidgets('the account button asks a stranger to sign in', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('nav-account')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('the account button opens the profile of a signed-in user', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);

    await tester.tap(find.byKey(const ValueKey('nav-account')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('opens the services of a region', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomRegions>().call(any())).thenAnswer(
      (_) async =>
          const Success<List<Region>>([Region(id: 4, name: 'Barzeh Hills')]),
    );
    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 1,
              name: 'Al Asad',
              categoryName: 'Restaurants',
              address: 'Damascus',
              rating: 0,
              reviewsCount: 0,
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Barzeh Hills'));
    await tester.pumpAndSettle();

    final page = find.byType(ServicesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Al Asad')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Restaurants')),
      findsOneWidget,
    );

    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.region);
    expect(params.scopeId, 4);
  });

  testWidgets('shows the top-rated rail on the home feed', (tester) async {
    await _pumpApp(tester);

    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 5,
              name: 'Al Asad',
              slug: 'al-asad',
              categoryName: 'Restaurants',
              regionName: 'Mazzeh',
              rating: 4.9,
              reviewsCount: 12,
              distanceText: '400 m',
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    final rail = find.byType(TopRatedRail);
    expect(rail, findsOneWidget);
    expect(find.text('Top rated services'), findsOneWidget);
    expect(
      find.descendant(of: rail, matching: find.text('Al Asad')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('Mazzeh · Restaurants')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('4.9')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('400 m')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: rail,
        matching: find.byKey(const ValueKey('favorite-5')),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => getIt<FavoritesRepository>().add('al-asad')).called(1);
    expect(find.text('Added to favorites'), findsOneWidget);

    final request = _lastServicePageRequestOf(ServiceScope.topRated);
    expect(request.authenticated, isFalse);
    expect(request.userLat, isNull);
  });

  testWidgets('shows the nearest rail with the distances it sorted by', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      return params.scope == ServiceScope.nearby
          ? const Success(
              ServicePage(
                services: [
                  ServiceSummary(
                    id: 7,
                    name: 'Al Baraka',
                    categoryName: 'Bakery',
                    regionName: 'Barzeh',
                    distanceText: '0 m',
                  ),
                ],
                hasMore: false,
                mode: ServiceListingMode.nearby,
              ),
            )
          : const Success(ServicePage(services: [], hasMore: false));
    });

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    final rail = find.byType(NearbyRail);
    expect(rail, findsOneWidget);
    expect(find.text('Nearest to you'), findsOneWidget);
    expect(
      find.descendant(of: rail, matching: find.text('Al Baraka')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.text('0 m')),
      findsOneWidget,
    );

    final request = _lastServicePageRequestOf(ServiceScope.nearby);
    expect(request.userLat, 33.51);
    expect(request.userLng, 36.29);
  });

  testWidgets('the rail says what it shows when no location was sent', (
    tester,
  ) async {
    await _pumpApp(tester);

    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      return params.scope == ServiceScope.nearby
          ? const Success(
              ServicePage(
                services: [ServiceSummary(id: 8, name: 'Random Row')],
                hasMore: false,
                mode: ServiceListingMode.random,
              ),
            )
          : const Success(ServicePage(services: [], hasMore: false));
    });

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Picked for you'), findsOneWidget);
    expect(find.text('Nearest to you'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(NearbyRail),
        matching: find.text('Random Row'),
      ),
      findsOneWidget,
    );
    expect(_lastServicePageRequestOf(ServiceScope.nearby).userLat, isNull);
  });

  testWidgets('a nearby listing that will not load leaves the feed alone', (
    tester,
  ) async {
    await _pumpApp(tester);

    when(() => getIt<GetServicePage>().call(any())).thenAnswer((
      invocation,
    ) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      return params.scope == ServiceScope.nearby
          ? const FailureResult(ServerFailure())
          : const Success(
              ServicePage(
                services: [ServiceSummary(id: 9, name: 'Al Asad')],
                hasMore: false,
              ),
            );
    });

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    // A rail with nothing to show collapses, and the finder skips the subtree
    // of a zero-sized box, so the feed never reserves a gap for the failure.
    expect(find.byType(NearbyRail), findsNothing);
    expect(find.text('Nearest to you'), findsNothing);
    expect(find.text('Picked for you'), findsNothing);
    // The top-rated rail still carries its own list.
    expect(find.text('Al Asad'), findsOneWidget);
  });

  testWidgets('asks the signed-in top-ten endpoint once a token exists', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900');
    await tester.pumpAndSettle();

    final request = _lastServicePageRequestOf(ServiceScope.topRated);
    expect(request.scope, ServiceScope.topRated);
    expect(request.authenticated, isTrue);
  });

  testWidgets('opens favorites from the drawer and drops a removed heart', (
    tester,
  ) async {
    await _pumpApp(tester);

    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 2,
              name: 'Imran',
              slug: 'amran-1',
              categoryName: 'Restaurants',
              isFavorited: true,
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-favorites')));
    await tester.pumpAndSettle();

    final page = find.byType(ServicesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.byIcon(Icons.favorite_rounded)),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('favorite-2')));
    await tester.pumpAndSettle();

    verify(() => getIt<FavoritesRepository>().remove('amran-1')).called(1);
    expect(find.text('Removed from favorites'), findsOneWidget);
    expect(find.text('Imran'), findsNothing);
    expect(
      find.text(
        'No favorites yet — tap the heart on a service to keep it here.',
      ),
      findsOneWidget,
    );

    final params = _lastServicePageRequest();
    expect(params.scope, ServiceScope.favorites);
    expect(params.scopeId, isNull);
  });

  testWidgets('adds a favorite from a category listing', (tester) async {
    await _pumpApp(tester);

    when(() => getIt<GetRandomCategories>().call(any())).thenAnswer(
      (_) async => const Success<List<ExploreCategory>>([
        ExploreCategory(id: 1, name: 'Shawarma Streets'),
      ]),
    );
    when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
      (_) async => const Success(
        CategoryPage(
          categories: [ExploreCategory(id: 1, name: 'Shawarma Streets')],
          hasMore: false,
        ),
      ),
    );
    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 9,
              name: 'Imran',
              slug: 'amran-9',
              regionName: 'Mazzeh',
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('categories-see-all')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(CategoriesPage),
        matching: find.text('Shawarma Streets'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('favorite-9')));
    await tester.pumpAndSettle();

    verify(() => getIt<FavoritesRepository>().add('amran-9')).called(1);
    expect(find.text('Added to favorites'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('favorites ask to sign in when no account exists', (
    tester,
  ) async {
    await _pumpApp(tester);

    when(
      () => getIt<GetServicePage>().call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-favorites')));
    await tester.pumpAndSettle();

    expect(
      find.text('Favorites need an account. Sign in and try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('the home field hands its words to the services search', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([
      const ServiceSummary(
        id: 5,
        name: 'Al Asad',
        categoryName: 'Restaurants',
        rating: 4.9,
        reviewsCount: 12,
      ),
    ]);

    await _openBackendSearch(tester, 'الاسد');

    expect(find.byType(ServicesSearchPage), findsOneWidget);
    expect(find.text('Al Asad'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);

    final query = _lastSearchRequest();
    expect(query.text, 'الاسد');
    expect(query.locale, 'en');
    expect(query.authenticated, isFalse);
    expect(query.categoryId, isNull);
  });

  testWidgets('a signed-in search asks the endpoint that knows favorites', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);

    await _openBackendSearch(tester, 'الاسد');

    final query = _lastSearchRequest();
    expect(query.authenticated, isTrue);
    expect(find.text('Al Asad'), findsOneWidget);
  });

  testWidgets('the location the user allowed travels without an order', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);

    await _openBackendSearch(tester, 'الاسد');

    final query = _lastSearchRequest();
    expect(query.userLat, 33.51);
    expect(query.userLng, 36.29);
    expect(query.sort, isNull);
  });

  testWidgets('a category chosen in the sheet narrows the words on screen', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);
    when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
      (_) async => const Success(
        CategoryPage(
          categories: [ExploreCategory(id: 1, name: 'Restaurants')],
          hasMore: false,
        ),
      ),
    );

    await _openBackendSearch(tester, 'الاسد');
    await _chooseFromSheet(
      tester,
      tileKey: 'filter-category',
      search: 'res',
      option: 'Restaurants',
    );

    final query = _lastSearchRequest();
    expect(query.text, 'الاسد');
    expect(query.categoryId, 1);
    expect(find.text('Restaurants'), findsWidgets);
  });

  testWidgets('a region chosen in its sheet narrows the words too', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);
    when(() => getIt<GetRegionPage>().call(any())).thenAnswer(
      (_) async => const Success(
        RegionPage(regions: [Region(id: 4, name: 'Barzeh')], hasMore: false),
      ),
    );

    await _openBackendSearch(tester, 'الاسد');
    await _chooseFromSheet(
      tester,
      tileKey: 'filter-region',
      search: 'bar',
      option: 'Barzeh',
    );

    final query = _lastSearchRequest();
    expect(query.regionId, 4);
    expect(query.categoryId, isNull);
  });

  testWidgets('the order and the minimum rating reach the endpoint', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);

    await _openBackendSearch(tester, 'الاسد');

    await _chooseFromMenu(tester, 'filter-sort', 'Nearest');
    await _chooseFromMenu(tester, 'filter-rating', '4.0+');

    final query = _lastSearchRequest();
    expect(query.sort, ServiceSort.distance);
    expect(query.minRating, 4);
  });

  testWidgets('clearing the filters leaves the words and searches again', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);

    await _openBackendSearch(tester, 'الاسد');
    await _chooseFromMenu(tester, 'filter-sort', 'Top rated');

    expect(find.byKey(const ValueKey('search-clear-filters')), findsOneWidget);
    final clear = find.byKey(const ValueKey('search-clear-filters'));
    await tester.ensureVisible(clear);
    await tester.pumpAndSettle();
    await tester.tap(clear);
    await tester.pumpAndSettle();

    final query = _lastSearchRequest();
    expect(query.text, 'الاسد');
    expect(query.sort, isNull);
    expect(query.minRating, isNull);
    expect(find.byKey(const ValueKey('search-clear-filters')), findsNothing);
  });

  testWidgets('a search that matched nothing says so without a retry', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _openBackendSearch(tester, 'الاسد');

    expect(find.text('Nothing matched that search'), findsOneWidget);
    expect(find.byKey(const ValueKey('search-retry')), findsNothing);
  });

  testWidgets('a failed search is retried from the message', (tester) async {
    await _pumpApp(tester);
    _stubSearchFailure();

    await _openBackendSearch(tester, 'الاسد');

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );

    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);
    await tester.tap(find.byKey(const ValueKey('search-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Al Asad'), findsOneWidget);
    expect(_searchLog.length, 2);
  });

  testWidgets('typing pauses before the next request', (tester) async {
    await _pumpApp(tester);
    _stubSearchResults([const ServiceSummary(id: 5, name: 'Al Asad')]);

    await _openBackendSearch(tester, 'ال');
    expect(_searchLog.length, 1);

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'الاسد');
    await tester.pump();
    expect(_searchLog.length, 1);

    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();
    expect(_searchLog.length, 2);
    expect(_lastSearchRequest().text, 'الاسد');
  });

  testWidgets('the next page lands below what is already on screen', (
    tester,
  ) async {
    await _pumpApp(tester);
    _stubSearchResults([
      const ServiceSummary(id: 5, name: 'Al Asad'),
    ], nextPage: 2);

    await _openBackendSearch(tester, 'الاسد');

    _stubSearchResults([const ServiceSummary(id: 6, name: 'Al Asad Two')]);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(find.text('Al Asad'), findsOneWidget);
    expect(find.text('Al Asad Two'), findsOneWidget);
    expect(_searchLog.length, 2);
    expect(_lastSearchRequest().page, 2);
  });

  testWidgets('the drawer offers login and register while signed out', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-login')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-register')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-account')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('password-field')), findsOneWidget);
  });

  testWidgets('an empty login form never reaches the endpoint', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsWidgets);
    verifyNever(() => getIt<AuthRepository>().login(any()));
  });

  testWidgets('signing in stores the token and greets the account', (
    tester,
  ) async {
    await _pumpApp(tester);
    when(() => getIt<AuthRepository>().login(any())).thenAnswer((_) async {
      await getIt<TokenRepository>().saveToken('t-700');
      return const Success(AuthSession(user: _imran, token: 't-700'));
    });

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('login-field')),
      ' 0944444444 ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'secret1',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<AuthRepository>().login(
        const Credentials(login: '0944444444', password: 'secret1'),
      ),
    ).called(1);
    expect(find.byType(LoginPage), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Imran Alsalame'), findsOneWidget);
    expect(find.text('0944444444'), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-logout')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-login')), findsNothing);
  });

  testWidgets('a rejected login keeps the form and shows why', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('login-field')),
      '0944444444',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'wrong-one',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('These credentials do not match our records.'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('a login applies the language the account asked for', (
    tester,
  ) async {
    await _pumpApp(tester);
    when(() => getIt<AuthRepository>().login(any())).thenAnswer(
      (_) async => const Success(
        AuthSession(
          user: AuthUser(
            id: 12,
            fullName: 'Imran Alsalame',
            mobile: '0944444444',
            locale: 'ar',
          ),
          token: 't-700',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('login-field')),
      '0944444444',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'secret1',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    verify(() => getIt<LocaleRepository>().saveLocaleCode('ar')).called(1);
  });

  testWidgets('signing out from the drawer forgets the account', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Imran Alsalame'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('drawer-logout')));
    await tester.pumpAndSettle();

    verify(() => getIt<AuthRepository>().signOut()).called(1);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-login')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-account')), findsNothing);
  });

  testWidgets('the login form hands over to the register form', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-login')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-register')));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.byKey(const ValueKey('register-full-name')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-gender')), findsOneWidget);
  });

  testWidgets('a register that has to match twice stops before the API', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-register')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('register-full-name')),
      'Imran Alsalame',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-mobile')),
      '0944444444',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'secret1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm')),
      'secret2',
    );
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('The two passwords do not match'), findsOneWidget);
    verifyNever(() => getIt<AuthRepository>().register(any()));
  });

  testWidgets('a register without a chosen gender asks for one', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-register')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('register-full-name')),
      'Imran Alsalame',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-mobile')),
      '0944444444',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'secret1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm')),
      'secret1',
    );
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Choose your gender'), findsOneWidget);
    verifyNever(() => getIt<AuthRepository>().register(any()));
  });

  testWidgets('creating an account sends the choice and signs the user in', (
    tester,
  ) async {
    await _pumpApp(tester);
    when(() => getIt<AuthRepository>().register(any())).thenAnswer((_) async {
      await getIt<TokenRepository>().saveToken('t-800');
      return const Success(AuthSession(user: _imran, token: 't-800'));
    });

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-register')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('register-full-name')),
      'Imran Alsalame',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-mobile')),
      '0944444444',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'secret1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm')),
      'secret1',
    );
    await tester.tap(find.text('Female'));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    final registration =
        verify(
              () => getIt<AuthRepository>().register(captureAny()),
            ).captured.single
            as Registration;
    expect(registration.fullName, 'Imran Alsalame');
    expect(registration.mobile, '0944444444');
    expect(registration.gender, AuthGender.female);
    expect(registration.email, isNull);
    expect(registration.address, isNull);
    expect(registration.locale, 'en');

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-account')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-register')), findsNothing);
  });

  testWidgets('the register page offers the vendor application', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('drawer-register')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-vendor-join')));
    await tester.pumpAndSettle();

    expect(find.byType(VendorJoinPage), findsOneWidget);
    expect(find.byKey(const ValueKey('join-full-name')), findsOneWidget);
    expect(find.byKey(const ValueKey('join-region-tile')), findsOneWidget);
    expect(find.byKey(const ValueKey('join-category-tile')), findsOneWidget);
  });

  testWidgets('the signed-out drawer offers the vendor application', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-vendor-join')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('drawer-vendor-join')));
    await tester.pumpAndSettle();

    expect(find.byType(VendorJoinPage), findsOneWidget);
  });

  testWidgets('the application fills its region from the searched list', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openVendorJoin(tester);

    await _chooseFromSheet(
      tester,
      tileKey: 'join-region-tile',
      search: 'مزة',
      option: 'المزة',
    );

    verify(
      () => getIt<VendorPickerRepository>().regions(
        locale: any(named: 'locale'),
        query: 'مزة',
      ),
    ).called(1);
    expect(find.text('المزة'), findsOneWidget);
  });

  testWidgets('an application without a chosen region stops at the form', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openVendorJoin(tester);
    await _fillJoinAccount(tester);
    await _pickJoinGender(tester);
    await _scrollAndEnter(tester, 'join-name-ar', 'الاسد');
    await _scrollAndEnter(tester, 'join-name-en', 'Asad');

    await _scrollAndTap(tester, 'join-submit');

    expect(find.text('Choose the region your service is in'), findsOneWidget);
    verifyNever(() => getIt<AuthRepository>().joinRequest(any()));
  });

  testWidgets('a sent application signs the applicant straight in', (
    tester,
  ) async {
    await _pumpApp(tester);

    when(() => getIt<AuthRepository>().joinRequest(any())).thenAnswer((
      _,
    ) async {
      await getIt<TokenRepository>().saveToken('t-900');
      return const Success(AuthSession(user: _imran, token: 't-900'));
    });

    await _openVendorJoin(tester);
    await _fillJoinAccount(tester);
    await _pickJoinGender(tester);
    await _scrollAndEnter(tester, 'join-name-ar', 'الاسد');
    await _scrollAndEnter(tester, 'join-name-en', 'Asad');
    await _chooseFromSheet(
      tester,
      tileKey: 'join-region-tile',
      search: 'مزة',
      option: 'المزة',
    );
    await _chooseFromSheet(
      tester,
      tileKey: 'join-category-tile',
      search: 'مطاعم',
      option: 'مطاعم',
    );

    await _scrollAndTap(tester, 'join-submit');

    final application =
        verify(
              () => getIt<AuthRepository>().joinRequest(captureAny()),
            ).captured.single
            as JoinRequest;
    expect(application.fullName, 'Imran Alsalame');
    expect(application.gender, AuthGender.female);
    expect(application.regionId, 1);
    expect(application.categoryId, 4);
    expect(application.nameAr, 'الاسد');
    expect(application.email, isNull);
    expect(application.mainImage, isNull);

    expect(find.text('Request sent — an admin will review it'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-account')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-vendor-join')), findsNothing);
  });

  testWidgets('reports the failure instead of inventing places', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const FailureResult(NetworkFailure()),
    );

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.textContaining('Demo data'), findsNothing);
  });

  testWidgets('shows a location permission message when denied', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(
      find.text(
        'We use your location to find places around you. Please enable it in system settings.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('picks up location access granted while the app was away', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Open settings'), findsOneWidget);

    when(() => getIt<HasLocationAccess>()()).thenAnswer((_) async => true);
    when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
      (_) async =>
          const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('No services here yet'), findsOneWidget);
    expect(_lastServicePageRequestOf(ServiceScope.nearby).userLat, 33.51);
  });

  testWidgets('refresh retries location while access is blocked', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Open settings'), findsOneWidget);

    when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
      (_) async =>
          const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('No services here yet'), findsOneWidget);
  });

  testWidgets('the account tile opens the profile with the stored fields', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await _openProfile(tester);

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('profile-name')))
          .controller
          .text,
      'Imran Alsalame',
    );
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('profile-address')))
          .controller
          .text,
      'Straight Street',
    );
    expect(
      tester
          .widget<SegmentedButton<AuthGender>>(
            find.byKey(const ValueKey('profile-gender')),
          )
          .selected,
      {AuthGender.male},
    );
    verify(() => getIt<ProfileRepository>().load('en')).called(1);
  });

  testWidgets('editing the name saves the fields the endpoint edits', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await _openProfile(tester);

    await tester.enterText(
      find.byKey(const ValueKey('profile-name')),
      'Imran Hoteish',
    );
    await tester.tap(find.byKey(const ValueKey('profile-save')));
    await tester.pumpAndSettle();

    final edit =
        verify(
              () => getIt<ProfileRepository>().update(
                edit: captureAny(named: 'edit'),
                locale: 'en',
              ),
            ).captured.single
            as ProfileEdit;
    expect(edit.fullName, 'Imran Hoteish');
    expect(edit.gender, AuthGender.male);
    expect(edit.address, 'Straight Street');
    expect(find.text('Profile updated successfully'), findsOneWidget);
  });

  testWidgets('a rejected save shows the sentence the backend wrote', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(
      () => getIt<ProfileRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('The full name field is required.'),
      ),
    );

    await _openProfile(tester);
    await tester.enterText(find.byKey(const ValueKey('profile-name')), '');
    await tester.tap(find.byKey(const ValueKey('profile-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Required'), findsOneWidget);
    verifyNever(
      () => getIt<ProfileRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('a name the server rejects still leaves the form to fix', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(
      () => getIt<ProfileRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('The full name has already been taken.'),
      ),
    );

    await _openProfile(tester);
    await tester.enterText(
      find.byKey(const ValueKey('profile-name')),
      'Someone Else',
    );
    await tester.tap(find.byKey(const ValueKey('profile-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('The full name has already been taken.'), findsOneWidget);
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('the remove-photo button appears only with a picture', (
    tester,
  ) async {
    const withPicture = AuthUser(
      id: 12,
      fullName: 'Imran Alsalame',
      mobile: '0944444444',
      address: 'Straight Street',
      avatar: 'https://dalildimashq.com/storage/avatars/99.jpg',
    );
    var reads = 0;
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(() => getIt<ProfileRepository>().load(any())).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? withPicture : _profile);
    });

    await _openProfile(tester);
    expect(find.byKey(const ValueKey('profile-remove-photo')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-remove-photo')));
    await tester.pumpAndSettle();

    verify(() => getIt<ProfileRepository>().removeAvatar()).called(1);
    expect(find.byKey(const ValueKey('profile-remove-photo')), findsNothing);
    verify(() => getIt<ProfileRepository>().load('en')).called(2);
  });

  testWidgets('change photo uploads what the gallery handed back', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(() => getIt<AvatarPicker>().pick()).thenAnswer((_) async => _picked);

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-change-photo')));
    await tester.pumpAndSettle();

    verify(
      () =>
          getIt<ProfileRepository>().uploadAvatar(file: _picked, locale: 'en'),
    ).called(1);
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('backing out of the gallery uploads nothing', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _imran);

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-change-photo')));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<ProfileRepository>().uploadAvatar(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('the password page refuses a mismatch before the endpoint', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-password-tile')));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordPage), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('current-password-field')),
      'secret1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-password-field')),
      'secret2',
    );
    await tester.enterText(
      find.byKey(const ValueKey('confirm-password-field')),
      'secret3',
    );
    await tester.tap(find.byKey(const ValueKey('password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('The two passwords do not match'), findsOneWidget);
    verifyNever(() => getIt<ProfileRepository>().changePassword(any()));
  });

  testWidgets('a wrong current password is shown as the backend wrote it', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(() => getIt<ProfileRepository>().changePassword(any())).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('Current password is incorrect')),
    );

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-password-tile')));
    await tester.pumpAndSettle();
    await _fillPasswords(tester);
    await tester.tap(find.byKey(const ValueKey('password-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Current password is incorrect'), findsOneWidget);
    expect(find.byType(ChangePasswordPage), findsOneWidget);
  });

  testWidgets('a changed password reports the success and leaves', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-password-tile')));
    await tester.pumpAndSettle();
    await _fillPasswords(tester);
    await tester.tap(find.byKey(const ValueKey('password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Password changed successfully'), findsOneWidget);
    expect(find.byType(ChangePasswordPage), findsNothing);
  });

  testWidgets('deleting waits for the password before it asks', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-delete-tile')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This removes your account for good. Enter your password to confirm.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('delete-account-confirm')),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('delete-account-password')),
      '12345678',
    );
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('delete-account-confirm')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('canceling leaves the account alone', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-delete-tile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('delete-account-cancel')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    verifyNever(() => getIt<ProfileRepository>().deleteAccount(any()));
  });

  testWidgets('a vendor still holding services keeps its account', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(() => getIt<ProfileRepository>().deleteAccount(any())).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure(
          'Cannot delete vendor account with services. Contact admin first.',
        ),
      ),
    );

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-delete-tile')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('delete-account-password')),
      '12345678',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('delete-account-confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text(
        'Cannot delete vendor account with services. Contact admin first.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('delete-account-confirm')),
      findsOneWidget,
    );
    verifyNever(() => getIt<AuthRepository>().signOut());
  });

  testWidgets('confirming the deletion signs this device out', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _imran);

    await _openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-delete-tile')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('delete-account-password')),
      '12345678',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('delete-account-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<ProfileRepository>().deleteAccount('12345678'),
    ).called(1);
    expect(find.text('Account deleted'), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-login')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-account')), findsNothing);
  });

  testWidgets('a profile that will not load offers a retry', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    when(
      () => getIt<ProfileRepository>().load(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await _openProfile(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile-save')), findsNothing);
  });

  testWidgets('the drawer keeps the service row from a plain account', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _imran);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-account')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-vendor-service')), findsNothing);
    expect(find.byKey(const ValueKey('drawer-vendor-contacts')), findsNothing);
    expect(find.byKey(const ValueKey('drawer-vendor-images')), findsNothing);
    expect(find.byKey(const ValueKey('drawer-vendor-products')), findsNothing);
    expect(find.byKey(const ValueKey('drawer-vendor-amenities')), findsNothing);
    expect(find.byKey(const ValueKey('drawer-vendor-stories')), findsNothing);
  });

  testWidgets('a vendor account gets the service row and its fields', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    expect(find.byType(VendorServicePage), findsOneWidget);
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('vendor-name-ar')))
          .controller
          .text,
      'الاسد',
    );
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('vendor-maps-url')))
          .controller
          .text,
      'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
    );
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('vendor-lat')))
          .controller
          .text,
      '33.0',
    );
    expect(find.text('المزة · مطاعم'), findsOneWidget);
    verify(() => getIt<VendorRepository>().load('en')).called(1);
  });

  testWidgets('saving the form sends the nine fields the endpoint edits', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    await tester.enterText(
      find.byKey(const ValueKey('vendor-name-en')),
      'Asad',
    );
    await _scrollAndTap(tester, 'vendor-save');
    await tester.pumpAndSettle();

    final edit =
        verify(
              () => getIt<VendorRepository>().update(
                edit: captureAny(named: 'edit'),
                locale: 'en',
              ),
            ).captured.single
            as VendorServiceEdit;
    expect(edit.nameAr, 'الاسد');
    expect(edit.nameEn, 'Asad');
    expect(edit.addressAr, 'دمشق');
    expect(edit.googleMapsUrl, 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7');
    expect(edit.lat, 33.0);
    expect(edit.lng, isNull);
    expect(edit.descriptionEn, 'amran');
    expect(find.text('Service updated successfully'), findsOneWidget);
  });

  testWidgets('a rejected edit shows the sentence the backend wrote', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('The google maps url must be a valid URL.'),
      ),
    );

    await _openVendorService(tester);
    await _scrollAndTap(tester, 'vendor-save');
    await tester.pumpAndSettle();

    expect(
      find.text('The google maps url must be a valid URL.'),
      findsOneWidget,
    );
    expect(find.text('Service updated successfully'), findsNothing);
  });

  testWidgets('a coordinate outside the allowed range is caught here', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    await tester.enterText(find.byKey(const ValueKey('vendor-lat')), '91');
    await _scrollAndTap(tester, 'vendor-save');
    await tester.pumpAndSettle();

    expect(find.text('Latitude must be between -90 and 90'), findsOneWidget);
    verifyNever(
      () => getIt<VendorRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('a maps link that is not a link is caught here', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    await tester.enterText(
      find.byKey(const ValueKey('vendor-maps-url')),
      'maps.app.goo.gl',
    );
    await _scrollAndTap(tester, 'vendor-save');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a link starting with http or https'),
      findsOneWidget,
    );
    verifyNever(
      () => getIt<VendorRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('an empty name is refused before the request', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    await tester.enterText(find.byKey(const ValueKey('vendor-name-ar')), '');
    await _scrollAndTap(tester, 'vendor-save');
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    verifyNever(
      () => getIt<VendorRepository>().update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('removing the cover picture re-reads the service', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    var reads = 0;
    when(() => getIt<VendorRepository>().load('en')).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? _vendorService : _serviceWithoutImage);
    });

    await _openVendorService(tester);
    expect(find.byKey(const ValueKey('vendor-remove-image')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('vendor-remove-image')));
    await tester.pumpAndSettle();

    verify(getIt<VendorRepository>().removeMainImage).called(1);
    expect(reads, 2);
    expect(find.byKey(const ValueKey('vendor-remove-image')), findsNothing);
    expect(find.text('Remove cover photo'), findsNothing);
  });

  testWidgets('a refused removal shows what the backend said', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorRepository>().removeMainImage(),
    ).thenAnswer((_) async => const FailureResult(ServerFailure('No image')));

    await _openVendorService(tester);
    await tester.tap(find.byKey(const ValueKey('vendor-remove-image')));
    await tester.pumpAndSettle();

    expect(find.text('No image'), findsOneWidget);
    expect(find.byKey(const ValueKey('vendor-remove-image')), findsOneWidget);
  });

  testWidgets('the vendor password page keeps its own endpoint', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorService(tester);

    await _scrollAndTap(tester, 'vendor-password-tile');
    expect(find.byType(VendorPasswordPage), findsOneWidget);

    await _fillPasswords(tester);
    await tester.tap(find.byKey(const ValueKey('password-submit')));
    await tester.pumpAndSettle();

    final change =
        verify(
              () => getIt<VendorRepository>().changePassword(captureAny()),
            ).captured.single
            as PasswordChange;
    expect(change.currentPassword, 'secret1');
    expect(change.password, 'secret2');
    expect(find.text('Password changed successfully'), findsOneWidget);
    expect(find.byType(VendorPasswordPage), findsNothing);
    verifyNever(() => getIt<ProfileRepository>().changePassword(any()));
  });

  testWidgets('a service that will not load offers a retry', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorRepository>().load(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await _openVendorService(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('vendor-save')), findsNothing);
  });

  testWidgets('a vendor account gets the contact lines grouped by type', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);

    expect(find.byType(VendorContactsPage), findsOneWidget);
    expect(find.text('هاتف'), findsOneWidget);
    expect(find.text('بريد إلكتروني'), findsOneWidget);
    expect(find.text('0999111222'), findsOneWidget);
    expect(find.text('0999111333'), findsOneWidget);
    expect(find.text('amran1@gmail.com'), findsOneWidget);
    // The group header counts its own rows, so the number is the server's.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
  });

  testWidgets('adding a contact sends the type and the value it picked', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);
    await _openContactForm(tester);

    expect(find.byType(VendorContactFormPage), findsOneWidget);
    await _fillContactForm(tester, label: 'واتساب', value: '+9630933314349');

    final edit =
        verify(
              () => getIt<VendorContactRepository>().add(
                edit: captureAny(named: 'edit'),
                locale: any(named: 'locale'),
              ),
            ).captured.single
            as VendorContactEdit;
    expect(edit.type, 'whatsapp');
    expect(edit.value, '+9630933314349');
    expect(find.byType(VendorContactFormPage), findsNothing);
    expect(find.text('Contact saved'), findsOneWidget);
  });

  testWidgets('the type list the form offers comes from the endpoint', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);
    await _openContactForm(tester);
    await tester.tap(find.byKey(const ValueKey('contact-type-tile')));
    await tester.pumpAndSettle();

    verify(
      () =>
          getIt<VendorContactRepository>().types(locale: any(named: 'locale')),
    ).called(1);
    expect(find.widgetWithText(ListTile, 'هاتف'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'واتساب'), findsOneWidget);
  });

  testWidgets('a line without a value stops at the form', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);
    await _openContactForm(tester);
    await _chooseContactType(tester, 'واتساب');

    await tester.tap(find.byKey(const ValueKey('contact-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the number, address or link'), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-value-field')), findsOneWidget);
    verifyNever(
      () => getIt<VendorContactRepository>().add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('a line without a chosen type stops at the form', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);
    await _openContactForm(tester);
    await tester.enterText(
      find.byKey(const ValueKey('contact-value-field')),
      '+9630933314349',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('contact-save')));
    await tester.pumpAndSettle();

    expect(find.text('Choose the kind of contact'), findsOneWidget);
    verifyNever(
      () => getIt<VendorContactRepository>().add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('editing opens on the line and writes back to its id', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);
    await _openContactForm(tester, editId: 6);

    expect(
      tester
          .widget<AuthTextField>(
            find.byKey(const ValueKey('contact-value-field')),
          )
          .controller
          .text,
      'amran1@gmail.com',
    );
    expect(find.byKey(const ValueKey('contact-type-tile')), findsOneWidget);
    expect(find.text('بريد إلكتروني'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('contact-save')));
    await tester.pumpAndSettle();

    final edit =
        verify(
              () => getIt<VendorContactRepository>().update(
                id: 6,
                edit: captureAny(named: 'edit'),
                locale: any(named: 'locale'),
              ),
            ).captured.single
            as VendorContactEdit;
    expect(edit.type, 'email');
    expect(edit.value, 'amran1@gmail.com');
  });

  testWidgets('deleting asks first, then names the line it removes', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);

    await tester.tap(find.byKey(const ValueKey('contact-delete-3')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this contact?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('contact-delete-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorContactRepository>().remove(
        id: 3,
        locale: any(named: 'locale'),
      ),
    ).called(1);
  });

  testWidgets('canceling the question leaves the line where it is', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);

    await tester.tap(find.byKey(const ValueKey('contact-delete-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<VendorContactRepository>().remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    );
    expect(find.text('0999111333'), findsOneWidget);
  });

  testWidgets('the star moves to the line the vendor taps', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);

    await tester.tap(find.byKey(const ValueKey('contact-primary-3')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorContactRepository>().setPrimary(
        id: 3,
        locale: any(named: 'locale'),
      ),
    ).called(1);
  });

  testWidgets('the line that is already primary has no star to tap', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorContacts(tester);

    final button = tester.widget<IconButton>(
      find.byKey(const ValueKey('contact-primary-2')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a refused write shows the sentence the backend wrote', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorContactRepository>().add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(ServerFailure('The value is invalid.')),
    );
    await _openVendorContacts(tester);
    await _openContactForm(tester);
    await _fillContactForm(tester, label: 'واتساب', value: '+9630933314349');

    expect(find.text('The value is invalid.'), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-value-field')), findsOneWidget);
  });

  testWidgets('a contact list that will not load offers a retry', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorContactRepository>().contacts(
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await _openVendorContacts(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('contact-add')), findsNothing);

    when(
      () => getIt<VendorContactRepository>().contacts(
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_contactGroups));
    await tester.tap(find.byKey(const ValueKey('contacts-retry')));
    await tester.pumpAndSettle();

    expect(find.text('amran1@gmail.com'), findsOneWidget);
  });

  testWidgets('a vendor with no contacts is told the list is empty', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorContactRepository>().contacts(
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(<ContactGroup>[]));

    await _openVendorContacts(tester);

    expect(find.text('No contacts yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-add')), findsOneWidget);
  });

  testWidgets('the gallery shows each photo against the limit it was given', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorImages(tester);

    expect(find.byType(VendorImagesPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Service photos'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('image-tile-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('image-tile-2')), findsOneWidget);
    expect(find.text('2 of 20'), findsOneWidget);
    // Only the picture an admin has not seen yet is badged.
    expect(find.text('Waiting for approval'), findsOneWidget);
    verify(
      () => getIt<VendorImageRepository>().gallery(locale: 'en'),
    ).called(1);
  });

  testWidgets('adding picks a photo, posts it and reads the limit back', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<AvatarPicker>().pick(),
    ).thenAnswer((_) async => _pickedPhoto);

    await _openVendorImages(tester);
    await tester.tap(find.byKey(const ValueKey('image-add')));
    await tester.pumpAndSettle();

    verify(
      () =>
          getIt<VendorImageRepository>().add(file: _pickedPhoto, locale: 'en'),
    ).called(1);
    // The reply names only the one picture it stored, so the page shows the
    // gallery it re-reads instead of the echo.
    verify(
      () => getIt<VendorImageRepository>().gallery(locale: 'en'),
    ).called(2);
  });

  testWidgets('a canceled chooser sends no photo', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorImages(tester);

    await tester.tap(find.byKey(const ValueKey('image-add')));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<VendorImageRepository>().add(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );
    expect(find.text('2 of 20'), findsOneWidget);
  });

  testWidgets('a full gallery closes the add button and says so', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () =>
          getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_vendorImagesFull));

    await _openVendorImages(tester);

    expect(find.text('2 of 2'), findsOneWidget);
    expect(find.text('No room for another photo'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byKey(const ValueKey('image-add')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('deleting one photo asks first, then names the picture', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorImages(tester);

    await tester.tap(find.byKey(const ValueKey('image-delete-1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this photo?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('image-delete-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorImageRepository>().remove(id: 1, locale: 'en'),
    ).called(1);
    verify(
      () => getIt<VendorImageRepository>().gallery(locale: 'en'),
    ).called(2);
  });

  testWidgets('canceling the question leaves the photo where it is', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorImages(tester);

    await tester.tap(find.byKey(const ValueKey('image-delete-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<VendorImageRepository>().remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    );
    expect(find.byKey(const ValueKey('image-tile-2')), findsOneWidget);
  });

  testWidgets('deleting the set reports how many pictures went away', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorImages(tester);
    when(
      () =>
          getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_vendorImagesEmpty));

    await tester.tap(find.byKey(const ValueKey('images-delete-all')));
    await tester.pumpAndSettle();
    expect(find.text('Delete every photo of this service?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('images-clear-confirm')));
    await tester.pumpAndSettle();

    verify(() => getIt<VendorImageRepository>().clear(locale: 'en')).called(1);
    expect(find.text('Removed 2 photos'), findsOneWidget);
    expect(find.text('No photos yet'), findsOneWidget);
    // Nothing left to delete, so the button is gone with them.
    expect(find.byKey(const ValueKey('images-delete-all')), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a service with no photos is told the set is empty', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () =>
          getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_vendorImagesEmpty));

    await _openVendorImages(tester);

    expect(find.text('No photos yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('image-add')), findsOneWidget);
    expect(find.byKey(const ValueKey('images-delete-all')), findsNothing);
  });

  testWidgets('a gallery that will not load offers a retry', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () =>
          getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await _openVendorImages(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('image-add')), findsNothing);
    expect(find.byKey(const ValueKey('images-delete-all')), findsNothing);

    when(
      () =>
          getIt<VendorImageRepository>().gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_vendorImages));
    await tester.tap(find.byKey(const ValueKey('images-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('image-tile-1')), findsOneWidget);
  });

  testWidgets('a refused upload shows the sentence the backend wrote', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<AvatarPicker>().pick(),
    ).thenAnswer((_) async => _pickedPhoto);
    when(
      () => getIt<VendorImageRepository>().add(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('The image must be an image.')),
    );

    await _openVendorImages(tester);
    await tester.tap(find.byKey(const ValueKey('image-add')));
    await tester.pumpAndSettle();

    expect(find.text('The image must be an image.'), findsOneWidget);
    // A write that was refused reads nothing back, so the set stays as shown.
    verify(
      () => getIt<VendorImageRepository>().gallery(locale: 'en'),
    ).called(1);
    expect(find.text('2 of 20'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('the products list shows each row with its price and flags', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);

    expect(find.byType(VendorProductsPage), findsOneWidget);
    // The bar carries the field rather than a title, since narrowing the list
    // is the first thing a vendor does on it.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Search products…'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('product-row-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-row-7')), findsOneWidget);
    // The row keeps the language the app is showing, not the one it was stored in.
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('عصير'), findsOneWidget);
    expect(find.text('1,200 SYP'), findsOneWidget);
    expect(find.text('مقاهي · Quantity: 4'), findsOneWidget);
    // Only the product an admin has not seen, or that the vendor hid, is badged.
    expect(find.text('Waiting for approval'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.text('Not available'), findsNothing);
    verify(() => getIt<VendorProductRepository>().products(any())).called(1);
  });

  testWidgets('a product with no English half is still named', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(() => getIt<VendorProductRepository>().products(any())).thenAnswer(
      (_) async => const Success(
        VendorProductPage(products: [_juiceProduct], hasMore: false),
      ),
    );

    await _openVendorProducts(tester);

    expect(find.text('عصير'), findsOneWidget);
    // An approved product carries no waiting badge, only the one the vendor
    // hid it with.
    expect(find.text('Waiting for approval'), findsNothing);
    expect(find.text('Hidden'), findsOneWidget);
  });

  testWidgets('the words typed go out as q once typing pauses', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    final reads = _productRequests.length;

    await tester.enterText(
      find.byKey(const ValueKey('products-search-field')),
      'قهوة',
    );
    // Still typing, so nothing has been asked for yet.
    expect(_productRequests, hasLength(reads));

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_lastProductRequest().text, 'قهوة');
  });

  testWidgets('emptying the field asks for the whole list again', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.enterText(
      find.byKey(const ValueKey('products-search-field')),
      'coffee',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('products-search-clear')));
    await tester.pumpAndSettle();

    expect(_lastProductRequest().text, '');
    expect(find.text('Nothing matched that search'), findsNothing);
  });

  testWidgets('choosing a category narrows the list by its id', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);

    await _chooseFromSheet(
      tester,
      tileKey: 'filter-product-category',
      search: 'مق',
      option: 'مقاهي',
    );

    expect(_lastProductRequest().categoryId, 4);
    // The chip keeps the name so the vendor can see what is on.
    expect(find.text('مقاهي'), findsWidgets);
    expect(
      find.byKey(const ValueKey('products-clear-filters')),
      findsOneWidget,
    );
  });

  testWidgets('the status menu sends the approval state the endpoint spells', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);

    await _chooseFromMenu(tester, 'filter-product-status', 'Pending');

    expect(_lastProductRequest().status, VendorProductStatus.pending);

    await _chooseFromMenu(tester, 'filter-product-status', 'Any status');

    expect(_lastProductRequest().status, isNull);
  });

  testWidgets('clearing the filters drops the words and the state together', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await _chooseFromMenu(tester, 'filter-product-status', 'Approved');
    await tester.enterText(
      find.byKey(const ValueKey('products-search-field')),
      'قهوة',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final clear = find.byKey(const ValueKey('products-clear-filters'));
    await tester.ensureVisible(clear);
    await tester.pumpAndSettle();
    await tester.tap(clear);
    await tester.pumpAndSettle();

    expect(_lastProductRequest(), const VendorProductQuery(locale: 'en'));
    // With nothing on, the button that clears it is gone.
    expect(clear, findsNothing);
  });

  testWidgets('load more asks for the next page and appends to the rows', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _stubProductPages(
      tester,
      firstPage: _vendorProducts,
      secondPage: const VendorProductPage(
        products: [_coffeeProduct],
        hasMore: false,
        count: 21,
      ),
    );

    await _openVendorProducts(tester);

    final more = find.byKey(const ValueKey('products-load-more'));
    await tester.ensureVisible(more);
    await tester.pumpAndSettle();
    await tester.tap(more);
    await tester.pumpAndSettle();

    expect(_lastProductRequest().page, 2);
    expect(find.byKey(const ValueKey('product-row-3')), findsNWidgets(2));
    expect(more, findsNothing);
  });

  testWidgets('a shop with nothing to sell is told the list is empty', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorProductRepository>().products(any()),
    ).thenAnswer((_) async => const Success(_vendorProductsEmpty));

    await _openVendorProducts(tester);

    expect(find.text('No products yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('product-add')), findsOneWidget);
  });

  testWidgets('a listing that will not load offers a retry', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorProductRepository>().products(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await _openVendorProducts(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('product-add')), findsNothing);

    when(() => getIt<VendorProductRepository>().products(any())).thenAnswer((
      invocation,
    ) async {
      _productRequests.add(
        invocation.positionalArguments.single as VendorProductQuery,
      );
      return const Success(_vendorProducts);
    });
    await tester.tap(find.byKey(const ValueKey('products-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('product-row-3')), findsOneWidget);
  });

  testWidgets('the add form opens without the two flags the endpoint refuses', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);

    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();

    expect(find.byType(VendorProductFormPage), findsOneWidget);
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('product-name-ar')))
          .controller
          .text,
      isEmpty,
    );
    expect(find.byKey(const ValueKey('product-active')), findsNothing);
    expect(find.byKey(const ValueKey('product-available')), findsNothing);
    expect(find.byKey(const ValueKey('product-delete')), findsNothing);
  });

  testWidgets('the add form will not send a product with no name or price', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();

    await _scrollAndTap(tester, 'product-save');

    // Both the name and the price are the halves the endpoint requires.
    expect(find.text('Required'), findsNWidgets(2));
    expect(find.text('Enter a price from 0 to 9999999.99'), findsNothing);
    verifyNever(
      () => getIt<VendorProductRepository>().add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('the add form will not send a price the rules reject', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();

    await _scrollAndEnter(tester, 'product-name-ar', 'قهوة');
    await _scrollAndEnter(tester, 'product-price', '10000000');
    await _scrollAndEnter(tester, 'product-quantity', '1000000');
    await _scrollAndTap(tester, 'product-save');

    expect(find.text('Enter a price from 0 to 9999999.99'), findsOneWidget);
    expect(find.text('Enter a whole number up to 999999'), findsOneWidget);
  });

  testWidgets('a product with no category chosen is held back', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();

    await _scrollAndEnter(tester, 'product-name-ar', 'قهوة');
    await _scrollAndEnter(tester, 'product-price', '1200');
    await _scrollAndTap(tester, 'product-save');

    expect(
      find.text('Choose the category this product belongs to'),
      findsOneWidget,
    );
    verifyNever(
      () => getIt<VendorProductRepository>().add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('adding picks a category and a photo, posts them and closes', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<AvatarPicker>().pick(),
    ).thenAnswer((_) async => _pickedPng);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();

    await _chooseFromSheet(
      tester,
      tileKey: 'product-category-tile',
      search: 'مق',
      option: 'مقاهي',
    );
    await tester.tap(find.byKey(const ValueKey('product-pick-image')));
    await tester.pumpAndSettle();
    await _scrollAndEnter(tester, 'product-name-ar', 'قهوة');
    await _scrollAndEnter(tester, 'product-name-en', 'Coffee');
    await _scrollAndEnter(tester, 'product-price', '1200');
    await _scrollAndEnter(tester, 'product-quantity', '4');
    await _scrollAndTap(tester, 'product-save');

    verify(
      () => getIt<VendorProductRepository>().add(
        edit: const VendorProductEdit(
          categoryId: 4,
          nameAr: 'قهوة',
          nameEn: 'Coffee',
          price: 1200,
          quantity: 4,
        ),
        image: _pickedPng,
        locale: 'en',
      ),
    ).called(1);
    expect(find.text('Product saved'), findsOneWidget);
    expect(find.byType(VendorProductFormPage), findsNothing);
    // The list the form wrote through reads its first page back.
    verify(() => getIt<VendorProductRepository>().products(any())).called(2);
    expect(find.byKey(const ValueKey('product-row-3')), findsOneWidget);
  });

  testWidgets('editing opens filled and saves through the product id', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);

    await tester.tap(find.byKey(const ValueKey('product-row-3')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Edit product'),
      ),
      findsOneWidget,
    );
    // A whole price opens without a decimal the vendor then has to delete.
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('product-price')))
          .controller
          .text,
      '1200',
    );
    expect(
      tester
          .widget<AuthTextField>(
            find.byKey(const ValueKey('product-description-ar')),
          )
          .controller
          .text,
      isEmpty,
    );
    // Only the edit call takes the two flags.
    expect(find.byKey(const ValueKey('product-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-available')), findsOneWidget);

    await _scrollAndEnter(tester, 'product-name-ar', 'قهوة تركي');
    await _scrollAndEnter(tester, 'product-price', '1500');
    await tester.tap(find.byKey(const ValueKey('product-active')));
    await tester.pumpAndSettle();
    await _scrollAndTap(tester, 'product-save');

    verify(
      () => getIt<VendorProductRepository>().update(
        id: 3,
        edit: const VendorProductEdit(
          categoryId: 4,
          nameAr: 'قهوة تركي',
          nameEn: 'Coffee',
          price: 1500,
          quantity: 4,
          isActive: false,
          isAvailable: true,
        ),
        image: null,
        locale: 'en',
      ),
    ).called(1);
    expect(find.byType(VendorProductFormPage), findsNothing);
  });

  testWidgets('deleting asks first, then names the product and closes', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-row-3')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('product-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this product?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('product-delete-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorProductRepository>().remove(id: 3, locale: 'en'),
    ).called(1);
    expect(find.text('Product deleted'), findsOneWidget);
    expect(find.byType(VendorProductFormPage), findsNothing);
    verify(() => getIt<VendorProductRepository>().products(any())).called(2);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('backing out of the question leaves the product alone', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-row-3')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('product-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<VendorProductRepository>().remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    );
    expect(find.byType(VendorProductFormPage), findsOneWidget);
  });

  testWidgets('a refused write shows the sentence the backend wrote', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorProductRepository>().add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('The price must be a number.')),
    );

    await _openVendorProducts(tester);
    await tester.tap(find.byKey(const ValueKey('product-add')));
    await tester.pumpAndSettle();
    await _chooseFromSheet(
      tester,
      tileKey: 'product-category-tile',
      search: '',
      option: 'مقاهي',
    );
    await _scrollAndEnter(tester, 'product-name-ar', 'قهوة');
    await _scrollAndEnter(tester, 'product-price', '1200');
    await _scrollAndTap(tester, 'product-save');

    expect(find.text('The price must be a number.'), findsOneWidget);
    // A write that was refused reads nothing back, so the form stays open with
    // what was typed still in it.
    expect(find.byType(VendorProductFormPage), findsOneWidget);
    verify(() => getIt<VendorProductRepository>().products(any())).called(1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('the amenities list shows each line with its other name', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);

    expect(find.byType(VendorAmenitiesPage), findsOneWidget);
    expect(find.byKey(const ValueKey('amenity-row-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('amenity-row-2')), findsOneWidget);
    // The row keeps the language the app is showing and puts the other half
    // underneath, so a vendor reads both names they wrote.
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('واي فاي'), findsOneWidget);
    // Only the line an admin has not seen is badged, and the badge rides on
    // the same line as the other name.
    expect(find.text('قاعة اجتماعات · Waiting for approval'), findsOneWidget);
    expect(find.text('2 of 20'), findsOneWidget);
    verify(
      () => getIt<VendorAmenityRepository>().gallery(locale: 'en'),
    ).called(1);
  });

  testWidgets('a line the vendor wrote in Arabic alone is still named', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _stubAmenityGallery(
      tester,
      const VendorAmenityGallery(
        amenities: [
          VendorAmenity(id: 5, nameAr: 'مواقف سيارات', isApproved: true),
        ],
        maxAllowed: 20,
        canAdd: true,
      ),
    );
    await _openVendorAmenities(tester);

    expect(find.text('مواقف سيارات'), findsOneWidget);
    // With no second name there is nothing to stack under the title.
    expect(find.byKey(const ValueKey('amenity-row-5')), findsOneWidget);
  });

  testWidgets(
    'a service that offered nothing says so, and has nothing to clear',
    (tester) async {
      await _pumpApp(tester, token: 't-900', account: _vendorImran);
      await _stubAmenityGallery(tester, _vendorAmenitiesEmpty);
      await _openVendorAmenities(tester);

      expect(find.text('No amenities yet'), findsOneWidget);
      expect(find.byKey(const ValueKey('amenities-delete-all')), findsNothing);
      expect(find.byKey(const ValueKey('amenity-add')), findsOneWidget);
    },
  );

  testWidgets('no room for another amenity holds the add button', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _stubAmenityGallery(tester, _vendorAmenitiesFull);
    await _openVendorAmenities(tester);

    expect(find.text('No room for another amenity'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(
            find.byKey(const ValueKey('amenity-add')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('a gallery that will not load is read again on demand', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorAmenityRepository>().gallery(
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));
    await _openVendorAmenities(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );

    await _stubAmenityGallery(tester, _vendorAmenities);
    await tester.tap(find.byKey(const ValueKey('amenities-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('amenity-row-1')), findsOneWidget);
  });

  testWidgets('the add form opens with nothing typed and no deleting', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-add')));
    await tester.pumpAndSettle();

    expect(find.byType(VendorAmenityFormPage), findsOneWidget);
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('amenity-name-ar')))
          .controller
          .text,
      isEmpty,
    );
    expect(
      find.text('The amenity reaches customers once an admin approves it.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('amenity-delete')), findsNothing);
  });

  testWidgets('the add form will not send an amenity with no name', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-add')));
    await tester.pumpAndSettle();

    await _scrollAndTap(tester, 'amenity-save');

    expect(find.text('Required'), findsOneWidget);
    verifyNever(
      () => getIt<VendorAmenityRepository>().add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    );
  });

  testWidgets('adding writes both names and reads the limit back', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-add')));
    await tester.pumpAndSettle();

    await _scrollAndEnter(tester, 'amenity-name-ar', 'تكييف');
    await _scrollAndEnter(tester, 'amenity-name-en', 'Air Conditioning');
    await _scrollAndTap(tester, 'amenity-save');

    expect(find.text('Amenity saved'), findsOneWidget);
    expect(find.byType(VendorAmenityFormPage), findsNothing);
    verify(
      () => getIt<VendorAmenityRepository>().add(
        edit: const VendorAmenityEdit(
          nameAr: 'تكييف',
          nameEn: 'Air Conditioning',
        ),
        locale: 'en',
      ),
    ).called(1);
    // The write reply names one line; only the read says how full the set is.
    verify(
      () => getIt<VendorAmenityRepository>().gallery(locale: 'en'),
    ).called(2);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('an amenity that already exists is answered in its own words', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<VendorAmenityRepository>().add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('This amenity already exists')),
    );
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-add')));
    await tester.pumpAndSettle();

    await _scrollAndEnter(tester, 'amenity-name-ar', 'واي فاي');
    await _scrollAndTap(tester, 'amenity-save');

    expect(find.text('This amenity already exists'), findsOneWidget);
    // A refused write reads nothing back, so the form keeps what was typed.
    expect(find.byType(VendorAmenityFormPage), findsOneWidget);
    verify(
      () => getIt<VendorAmenityRepository>().gallery(locale: 'en'),
    ).called(1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('the form edits the line the row named', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-row-1')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('amenity-name-ar')))
          .controller
          .text,
      'واي فاي',
    );
    expect(
      tester
          .widget<AuthTextField>(find.byKey(const ValueKey('amenity-name-en')))
          .controller
          .text,
      'Wi-Fi',
    );
    expect(find.byKey(const ValueKey('amenity-delete')), findsOneWidget);

    await _scrollAndEnter(tester, 'amenity-name-en', 'Wireless');
    await _scrollAndTap(tester, 'amenity-save');

    verify(
      () => getIt<VendorAmenityRepository>().update(
        id: 1,
        edit: const VendorAmenityEdit(nameAr: 'واي فاي', nameEn: 'Wireless'),
        locale: 'en',
      ),
    ).called(1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('deleting from the form asks first, then removes the line', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-row-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('amenity-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('amenity-delete-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorAmenityRepository>().remove(id: 1, locale: 'en'),
    ).called(1);
    expect(find.text('Amenity deleted'), findsOneWidget);
    expect(find.byType(VendorAmenityFormPage), findsNothing);
    verify(
      () => getIt<VendorAmenityRepository>().gallery(locale: 'en'),
    ).called(2);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('backing out of the question leaves the amenity alone', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);
    await tester.tap(find.byKey(const ValueKey('amenity-row-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('amenity-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () => getIt<VendorAmenityRepository>().remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    );
    expect(find.byType(VendorAmenityFormPage), findsOneWidget);
  });

  testWidgets('clearing the set counts what went away', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);

    await tester.tap(find.byKey(const ValueKey('amenities-delete-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('amenities-clear-confirm')));
    await tester.pumpAndSettle();

    verify(
      () => getIt<VendorAmenityRepository>().clear(locale: 'en'),
    ).called(1);
    expect(find.text('Removed 2 amenities'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('backing out of the clear question sends nothing', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorAmenities(tester);

    await tester.tap(find.byKey(const ValueKey('amenities-delete-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(
      () =>
          getIt<VendorAmenityRepository>().clear(locale: any(named: 'locale')),
    );
    expect(find.byKey(const ValueKey('amenity-row-1')), findsOneWidget);
  });

  testWidgets('the drawer hands a vendor the story form', (tester) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);

    expect(find.byType(VendorStoryFormPage), findsOneWidget);
    // The three types the endpoint takes, offered as chips.
    for (final label in const ['Photo', 'Video', 'Poll']) {
      expect(
        find.descendant(
          of: find.byType(VendorStoryFormPage),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
    expect(find.byKey(const ValueKey('story-pick-file')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(VendorStoryFormPage),
        matching: find.text('Publish story'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a photo story is refused until the picture is chosen', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);

    await _scrollAndTap(tester, 'story-save');

    expect(find.text('Choose the photo this story shows'), findsOneWidget);
    verifyNever(
      () => getIt<VendorStoryRepository>().add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a chosen photo posts the story and closes the form', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<StoryFilePicker>().pickImage(),
    ).thenAnswer((_) async => _pickedPng);
    await _openVendorStory(tester);

    await _scrollAndTap(tester, 'story-pick-file');
    // The picture is previewed before it is uploaded, so it has to decode.
    expect(
      find.descendant(
        of: find.byType(VendorStoryFormPage),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );

    await _scrollAndEnter(tester, 'story-caption-ar', 'قهوة');
    await _scrollAndTap(tester, 'story-save');

    verify(
      () => getIt<VendorStoryRepository>().add(
        edit: const VendorStoryEdit(
          type: VendorStoryType.image,
          captionAr: 'قهوة',
        ),
        file: _pickedPng,
        locale: 'en',
      ),
    ).called(1);
    expect(find.text('Story created, waiting for approval'), findsOneWidget);
    expect(find.byType(VendorStoryFormPage), findsNothing);
  });

  testWidgets('a clip is chosen through the video picker and named', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<StoryFilePicker>().pickVideo(),
    ).thenAnswer((_) async => _pickedClip);
    await _openVendorStory(tester);

    await _scrollAndTap(tester, 'story-type-video');
    await _scrollAndTap(tester, 'story-pick-file');
    expect(find.text('story.mp4'), findsOneWidget);

    await _scrollAndTap(tester, 'story-save');

    verify(
      () => getIt<VendorStoryRepository>().add(
        edit: const VendorStoryEdit(type: VendorStoryType.video),
        file: _pickedClip,
        locale: 'en',
      ),
    ).called(1);
    expect(find.byType(VendorStoryFormPage), findsNothing);
  });

  testWidgets(
    'the file picked for one type is not sent with another',
    (tester) async {
      await _pumpApp(tester, token: 't-900', account: _vendorImran);
      when(
        () => getIt<StoryFilePicker>().pickImage(),
      ).thenAnswer((_) async => _pickedPng);
      await _openVendorStory(tester);

      await _scrollAndTap(tester, 'story-pick-file');
      await _scrollAndTap(tester, 'story-type-video');

      // The picture was for a photo story, so the video type asks for its own.
      await _scrollAndTap(tester, 'story-save');
      expect(find.text('Choose the video this story shows'), findsOneWidget);
      verifyNever(
        () => getIt<VendorStoryRepository>().add(
          edit: any(named: 'edit'),
          file: any(named: 'file'),
          locale: any(named: 'locale'),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a poll sends its question and the options that were written', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);

    await _scrollAndTap(tester, 'story-type-poll');
    // The story is the question, so no file is wanted.
    expect(find.byKey(const ValueKey('story-pick-file')), findsNothing);

    await _scrollAndEnter(tester, 'story-question-ar', 'أي نوع تفضل؟');
    await _scrollAndEnter(tester, 'story-option-ar-0', 'ساخن');
    await _scrollAndEnter(tester, 'story-option-ar-1', 'بارد');
    await _scrollAndTap(tester, 'story-option-add');
    expect(find.byKey(const ValueKey('story-option-ar-2')), findsOneWidget);

    // The third row was left blank, so it is not offered as a choice.
    await _scrollAndTap(tester, 'story-save');

    verify(
      () => getIt<VendorStoryRepository>().add(
        edit: const VendorStoryEdit(
          type: VendorStoryType.poll,
          poll: VendorStoryPollEdit(
            questionAr: 'أي نوع تفضل؟',
            options: [
              VendorStoryOptionEdit(optionAr: 'ساخن'),
              VendorStoryOptionEdit(optionAr: 'بارد'),
            ],
          ),
        ),
        file: null,
        locale: 'en',
      ),
    ).called(1);
    expect(find.byType(VendorStoryFormPage), findsNothing);
  });

  testWidgets('a row taken back leaves the choices that remain', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);
    await _scrollAndTap(tester, 'story-type-poll');
    await _scrollAndTap(tester, 'story-option-add');
    expect(find.byKey(const ValueKey('story-option-ar-2')), findsOneWidget);

    await _scrollAndTap(tester, 'story-option-remove-2');

    expect(find.byKey(const ValueKey('story-option-ar-2')), findsNothing);
    // Two rows is the fewest the endpoint takes, so they cannot go below it.
    expect(
      find.byKey(const ValueKey('story-option-remove-0')),
      findsNothing,
    );
  });

  testWidgets('a poll with one written option says it needs two', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);
    await _scrollAndTap(tester, 'story-type-poll');

    await _scrollAndEnter(tester, 'story-question-ar', 'أي نوع تفضل؟');
    await _scrollAndEnter(tester, 'story-option-ar-0', 'ساخن');
    await _scrollAndTap(tester, 'story-save');

    expect(find.text('A poll needs at least two options'), findsOneWidget);
    verifyNever(
      () => getIt<VendorStoryRepository>().add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a question left blank is caught before the call', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    await _openVendorStory(tester);
    await _scrollAndTap(tester, 'story-type-poll');

    await _scrollAndEnter(tester, 'story-option-ar-0', 'ساخن');
    await _scrollAndEnter(tester, 'story-option-ar-1', 'بارد');
    await _scrollAndTap(tester, 'story-save');

    expect(
      find.descendant(
        of: find.byType(VendorStoryFormPage),
        matching: find.text('Required'),
      ),
      findsOneWidget,
    );
    verifyNever(
      () => getIt<VendorStoryRepository>().add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a refused post shows the sentence the backend used', (
    tester,
  ) async {
    await _pumpApp(tester, token: 't-900', account: _vendorImran);
    when(
      () => getIt<StoryFilePicker>().pickImage(),
    ).thenAnswer((_) async => _pickedPng);
    when(
      () => getIt<VendorStoryRepository>().add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('The image field is required.'),
      ),
    );
    await _openVendorStory(tester);

    await _scrollAndTap(tester, 'story-pick-file');
    await _scrollAndTap(tester, 'story-save');

    expect(find.text('The image field is required.'), findsOneWidget);
    // The form keeps what was written so the vendor can fix it.
    expect(find.byType(VendorStoryFormPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
