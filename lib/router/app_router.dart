import 'package:go_router/go_router.dart';
import 'package:pokedex_flutter/screens/home_screen.dart';
import 'package:pokedex_flutter/screens/detail_screen.dart';
import 'package:pokedex_flutter/screens/favorites_screen.dart';
import 'package:pokedex_flutter/widgets/app_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (_, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'pokemon/:id',
                  name: 'details',
                  builder: (_, state) => DetailScreen(
                    id: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (_, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
