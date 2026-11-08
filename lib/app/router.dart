import 'package:go_router/go_router.dart';

import '../features/chat/presentation/pages/chat_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/places/domain/entities/place.dart';
import '../features/places/presentation/pages/home_page.dart';
import '../features/places/presentation/pages/place_details_page.dart';
import '../features/places/presentation/pages/stories_page.dart';
import '../features/profile/presentation/pages/change_password_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/regions/presentation/pages/regions_page.dart';
import '../features/services/presentation/pages/services_page.dart';
import '../features/services/presentation/pages/services_search_page.dart';
import '../features/stories/presentation/pages/service_story_list_page.dart';
import '../features/stories/presentation/pages/service_stories_page.dart';
import '../features/vendor/presentation/pages/vendor_join_page.dart';
import '../features/vendor/presentation/pages/vendor_amenity_form_page.dart';
import '../features/vendor/presentation/pages/vendor_amenities_page.dart';
import '../features/vendor/presentation/pages/vendor_contact_form_page.dart';
import '../features/vendor/presentation/pages/vendor_contacts_page.dart';
import '../features/vendor/presentation/pages/vendor_images_page.dart';
import '../features/vendor/presentation/pages/vendor_password_page.dart';
import '../features/vendor/presentation/pages/vendor_product_form_page.dart';
import '../features/vendor/presentation/pages/vendor_products_page.dart';
import '../features/vendor/presentation/pages/vendor_service_page.dart';
import '../features/vendor/presentation/pages/vendor_story_form_page.dart';
import 'splash_page.dart';

/// App navigation graph.
GoRouter createRouter({required OnboardingRepository onboarding}) => GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => SplashPage(onboarding: onboarding),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => OnboardingPage(repository: onboarding),
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/vendor/join-request',
      name: 'vendor-join-request',
      builder: (context, state) => const VendorJoinPage(),
    ),
    GoRoute(
      path: '/vendor/service',
      name: 'vendor-service',
      builder: (context, state) => const VendorServicePage(),
    ),
    GoRoute(
      path: '/vendor/service/password',
      name: 'vendor-change-password',
      builder: (context, state) => const VendorPasswordPage(),
    ),
    GoRoute(
      path: '/vendor/contacts',
      name: 'vendor-contacts',
      builder: (context, state) => const VendorContactsPage(),
    ),
    GoRoute(
      path: '/vendor/images',
      name: 'vendor-images',
      builder: (context, state) => const VendorImagesPage(),
    ),
    GoRoute(
      path: '/vendor/products',
      name: 'vendor-products',
      builder: (context, state) => const VendorProductsPage(),
    ),
    GoRoute(
      path: '/vendor/products/form',
      name: 'vendor-product-form',
      builder: (context, state) {
        final args = state.extra;
        // Deep link without the cubit to write through: go back home.
        if (args is! VendorProductFormArgs) return const HomePage();
        return VendorProductFormPage(args: args);
      },
    ),
    GoRoute(
      path: '/vendor/contacts/form',
      name: 'vendor-contact-form',
      builder: (context, state) {
        final args = state.extra;
        // Deep link without the cubit to write through: go back home.
        if (args is! VendorContactFormArgs) return const HomePage();
        return VendorContactFormPage(args: args);
      },
    ),
    GoRoute(
      path: '/vendor/amenities',
      name: 'vendor-amenities',
      builder: (context, state) => const VendorAmenitiesPage(),
    ),
    GoRoute(
      path: '/vendor/story',
      name: 'vendor-story',
      builder: (context, state) => const VendorStoryFormPage(),
    ),
    GoRoute(
      path: '/vendor/amenities/form',
      name: 'vendor-amenity-form',
      builder: (context, state) {
        final args = state.extra;
        // Deep link without the cubit to write through: go back home.
        if (args is! VendorAmenityFormArgs) return const HomePage();
        return VendorAmenityFormPage(args: args);
      },
    ),
    GoRoute(
      path: '/regions',
      name: 'regions',
      builder: (context, state) => const RegionsPage(),
    ),
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) {
        final args = state.extra;
        // Deep link without a listing payload: go back home.
        if (args is! ServicesRouteArgs) return const HomePage();
        return ServicesPage(
          scope: args.scope,
          scopeId: args.id,
          title: args.title,
        );
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final extra = state.extra;
        return ServicesSearchPage(
          initialQuery: extra is String
              ? extra
              : (state.uri.queryParameters['q'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'stories',
          name: 'stories',
          builder: (context, state) {
            final args = state.extra;
            if (args is! StoriesArgs || args.places.isEmpty) {
              // Deep link without payload: go back home.
              return const HomePage();
            }
            return StoriesPage(
              places: args.places,
              initialIndex: args.initialIndex,
            );
          },
        ),
        GoRoute(
          path: 'service-stories',
          name: 'service-stories',
          builder: (context, state) {
            final args = state.extra;
            if (args is! ServiceStoriesArgs || args.stories.isEmpty) {
              // Deep link without payload: go back home.
              return const HomePage();
            }
            return ServiceStoriesPage(
              stories: args.stories,
              initialIndex: args.initialIndex,
            );
          },
        ),
        GoRoute(
          path: '/service-stories/list',
          name: 'service-stories-list',
          builder: (context, state) {
            final args = state.extra;
            if (args is! ServiceStoryListArgs) {
              return const HomePage();
            }
            return ServiceStoryListPage(
              serviceId: args.serviceId,
              serviceName: args.serviceName,
            );
          },
        ),
        GoRoute(
          path: 'place',
          name: 'place-details',
          builder: (context, state) {
            final place = state.extra;
            if (place is! Place) {
              // Deep link without payload: go back home.
              return const HomePage();
            }
            return PlaceDetailsPage(place: place);
          },
        ),
        GoRoute(
          path: 'chat',
          name: 'place-chat',
          builder: (context, state) {
            final place = state.extra;
            if (place is! Place) {
              // Deep link without payload: go back home.
              return const HomePage();
            }
            return ChatPage(place: place);
          },
        ),
      ],
    ),
  ],
);
