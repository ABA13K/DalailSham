import 'package:go_router/go_router.dart';

import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/places/domain/entities/place.dart';
import '../features/places/presentation/pages/home_page.dart';
import '../features/places/presentation/pages/place_details_page.dart';
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
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
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
          ],
        ),
      ],
    );
