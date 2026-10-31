import 'package:go_router/go_router.dart';

import '../features/chat/presentation/pages/chat_page.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/places/domain/entities/place.dart';
import '../features/places/presentation/pages/home_page.dart';
import '../features/places/presentation/pages/place_details_page.dart';
import '../features/places/presentation/pages/stories_page.dart';
import '../features/regions/presentation/pages/regions_page.dart';
import '../features/services/presentation/pages/services_page.dart';
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
