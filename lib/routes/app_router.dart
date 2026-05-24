import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/features/dashboard/presentation/dashboard_screen.dart';
import 'package:labour_party/features/history/presentation/history_screen.dart';
import 'package:labour_party/features/analytics/presentation/analytics_screen.dart';

import 'package:labour_party/features/dashboard/presentation/splash_screen.dart';
import 'package:labour_party/features/details/presentation/trip_details_screen.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/details/presentation/details_screen.dart';
import 'package:labour_party/features/settings/presentation/settings_screen.dart';
import 'package:labour_party/features/work/presentation/screens/add_edit_work_screen.dart';
import 'package:labour_party/shared/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) => const DetailsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/trip-details',
      builder: (context, state) => TripDetailsScreen(trip: state.extra as Trip),
    ),
    GoRoute(
      path: '/add-edit-work',
      builder: (context, state) {
        final isNew = (state.extra as Map<String, dynamic>?)?['isNew'] ?? true;
        return AddEditWorkScreen(isNew: isNew);
      },
    ),
  ],
);
