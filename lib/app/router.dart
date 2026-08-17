import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/core/views/pages/login_page.dart';
import '../modules/sales/views/pages/customer_page.dart';
import '../modules/sales/views/pages/dashboard_page.dart';
import '../shared/widgets/nav_rail_shell.dart';

GoRouter createRouter({String initialLocation = '/dashboard'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => NavRailShell(
        navigationShell: navigationShell,
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pelanggan',
              name: 'pelanggan',
              builder: (context, state) => const CustomerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/proposal',
              name: 'proposal',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Proposal'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/kontrak',
              name: 'kontrak',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Kontrak'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/harga',
              name: 'harga',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Kalkulator Harga'))),
            ),
          ],
        ),
      ],
    ),
  ],
);

final GoRouter appRouter = createRouter();
