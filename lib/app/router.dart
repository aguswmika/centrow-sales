import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/modules/core/views/pages/login_page.dart';
import 'package:centrow_sales/modules/sales/views/pages/customer_page.dart';
import 'package:centrow_sales/modules/sales/views/pages/customer_form_page.dart';
import 'package:centrow_sales/modules/sales/views/pages/proposal_page.dart';
import 'package:centrow_sales/modules/sales/views/pages/pricing_page.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/pages/pricing_preview_page.dart';
import 'package:centrow_sales/modules/sales/views/pages/proposal_document_page.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/widgets/nav_rail_shell.dart';

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
                  builder: (context, state) =>
                      CustomerFormPage(customerId: state.pathParameters['id']),
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
                  ProposalPage(initialProposalId: state.extra as String?),
              routes: [
                GoRoute(
                  path: ':id/pricing',
                  name: 'proposal-pricing',
                  builder: (context, state) =>
                      PricingPage(proposalId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'preview',
                      name: 'proposal-pricing-preview',
                      builder: (context, state) {
                        final extra = state.extra! as Map<String, dynamic>;
                        return PricingPreviewPage(
                          proposal: extra['proposal'] as Proposal,
                          preview: extra['preview'] as PricingPreview,
                          controller:
                              extra['controller']
                                  as PricingCalculatorController,
                          visitFrequency: extra['visitFrequency'] as int,
                          contractMonths: extra['contractMonths'] as int,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: ':id/document',
                  name: 'proposal-document',
                  builder: (context, state) => ProposalDocumentPage(
                    proposalId: state.pathParameters['id']!,
                  ),
                ),
              ],
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
      ],
    ),
  ],
);

final GoRouter appRouter = createRouter();
