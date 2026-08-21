import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/core/views/pages/login_page.dart';
import '../modules/sales/views/pages/customer_page.dart';
import '../modules/sales/views/pages/customer_form_page.dart';
import '../shared/network/auth_token_holder.dart';
import '../shared/widgets/nav_rail_shell.dart';

GoRouter createRouter({String? initialLocation}) => GoRouter(
  initialLocation:
      initialLocation ??
      (AuthTokenHolder.instance.hasToken ? '/customers' : '/login'),
  redirect: (context, state) {
    final hasToken = AuthTokenHolder.instance.hasToken;
    final isLoggingIn = state.matchedLocation == '/login';
    final isDashboard = state.matchedLocation == '/dashboard';

    if (!hasToken && !isLoggingIn) {
      return '/login';
    }
    if (hasToken && (isLoggingIn || isDashboard)) {
      return '/customers';
    }
    return null;
  },
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
              path: '/customers',
              name: 'customers',
              builder: (context, state) => const CustomerPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create-customer',
                  builder: (context, state) => const CustomerFormPage(),
                ),
                GoRoute(
                  path: ':id/edit',
                  name: 'edit-customer',
                  builder: (context, state) => CustomerFormPage(
                    customerId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/proposals',
              name: 'proposals',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Proposal'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/contracts',
              name: 'contracts',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Kontrak'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pricings',
              name: 'pricings',
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
