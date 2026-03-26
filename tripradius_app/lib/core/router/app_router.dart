import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/web_auth_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/places/presentation/pages/saved_places_page.dart';
import '../../features/places/presentation/pages/place_details_page.dart';
import '../../features/itinerary/presentation/pages/itinerary_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_shell.dart';

// Route name constants
class AppRoutes {
  static const welcome = '/';
  static const webAuth = '/auth/web';
  static const explore = '/explore';
  static const saved = '/saved';
  static const placeDetails = '/places/:placeId';
  static const itinerary = '/itinerary';
  static const profile = '/profile';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.welcome,
  routes: [
    // ── Public ──────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoutes.webAuth,
      builder: (context, state) => const WebAuthPage(),
    ),

    // ── Authenticated shell (BottomNavBar) ───────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.explore,
          pageBuilder: (context, state) => const NoTransitionPage(child: ExplorePage()),
        ),
        GoRoute(
          path: AppRoutes.saved,
          pageBuilder: (context, state) => const NoTransitionPage(child: SavedPlacesPage()),
        ),
        GoRoute(
          path: AppRoutes.itinerary,
          pageBuilder: (context, state) => const NoTransitionPage(child: ItineraryPage()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),

    // ── Full screen routes (outside shell) ───────────────────
    GoRoute(
      path: AppRoutes.placeDetails,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final placeId = state.pathParameters['placeId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return PlaceDetailsPage(placeId: placeId, extra: extra);
      },
    ),
  ],
);
