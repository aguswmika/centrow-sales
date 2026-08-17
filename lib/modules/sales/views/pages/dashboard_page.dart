import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../app/di.dart';
import '../../../../shared/state/ui_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../controllers/sales_dashboard_controller.dart';
import '../../entities/sales_dashboard.dart';
import '../widgets/expiring_contracts_list.dart';
import '../widgets/kpi_card.dart';
import '../widgets/pipeline_funnel_card.dart';
import '../widgets/recent_proposals_list.dart';

class DashboardPage extends StatefulWidget {
  final SalesDashboardController? controller;

  const DashboardPage({super.key, this.controller});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final SalesDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<SalesDashboardController>();
    if (widget.controller == null) {
      _controller.loadDashboard();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Watch.builder(
          builder: (context) {
            final state = _controller.state.value;

            return switch (state) {
              UiInitial() || UiLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
              UiFailure(:final failure) => ErrorView(
                message: failure.message,
                onRetry: _controller.loadDashboard,
              ),
              UiSuccess(:final data) => _buildDashboardContent(context, data),
            };
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    SalesDashboardSummary summary,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 720;

    return Column(
      children: [
        _buildFixedPageHeader(summary.userName, summary.branchName),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24.0 : 16.0,
              20.0,
              isTablet ? 24.0 : 16.0,
              36.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiSection(summary.kpis),
                const SizedBox(height: 20.0),
                if (isTablet)
                  _buildTabletTwoColumnLayout(summary)
                else
                  _buildMobileLayout(summary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedPageHeader(String userName, String branchName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final greeting = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, $userName 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3.0),
              Text(
                'Agustus 2026 · Sales Wilayah $branchName',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            children: [
              AppButton.secondary(
                text: 'Pelanggan',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                icon: const Icon(
                  Icons.person_add_outlined,
                  size: 15,
                  color: AppColors.text,
                ),
                onPressed: () {},
              ),
              AppButton(
                text: 'Proposal',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [greeting, const SizedBox(height: 12.0), actions],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 16.0),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiSection(List<KpiMetric> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          final cardWidth = (constraints.maxWidth - 12.0) / 2;
          return Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              for (final metric in kpis)
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(metric: metric),
                ),
            ],
          );
        }

        final cardWidth =
            (constraints.maxWidth - (kpis.length - 1) * 14.0) / kpis.length;
        return Row(
          children: [
            for (int i = 0; i < kpis.length; i++) ...[
              if (i > 0) const SizedBox(width: 14.0),
              SizedBox(
                width: cardWidth,
                child: KpiCard(metric: kpis[i]),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTabletTwoColumnLayout(SalesDashboardSummary summary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: PipelineFunnelCard(
            stages: summary.pipelineStages,
            segments: summary.clientSegments,
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              RecentProposalsList(proposals: summary.recentProposals),
              const SizedBox(height: 20.0),
              ExpiringContractsList(contracts: summary.expiringContracts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(SalesDashboardSummary summary) {
    return Column(
      children: [
        PipelineFunnelCard(
          stages: summary.pipelineStages,
          segments: summary.clientSegments,
        ),
        const SizedBox(height: 16.0),
        RecentProposalsList(proposals: summary.recentProposals),
        const SizedBox(height: 16.0),
        ExpiringContractsList(contracts: summary.expiringContracts),
      ],
    );
  }
}
