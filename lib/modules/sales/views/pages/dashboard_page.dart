import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../app/di.dart';
import '../../../../shared/state/ui_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/nav_rail_shell.dart';
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
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavRailShell(
      selectedIndex: 0,
      child: SafeArea(
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
              UiSuccess(:final data) => _buildDashboardContent(data),
            };
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(SalesDashboardSummary data) {
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      color: AppColors.brand,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(data.userName, data.branchName),
            const SizedBox(height: 20.0),
            _buildKpiSection(data.kpis),
            const SizedBox(height: 20.0),
            _buildMainGrid(data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String branchName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
              ),
              const SizedBox(height: 3.0),
              Text(
                'Agustus 2026 · Sales Wilayah $branchName',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text('+ Pelanggan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                textStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10.0),
            AppButton(
              text: 'Buat Proposal',
              height: 38.0,
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiSection(List<KpiMetric> kpis) {
    return Row(
      children: kpis.map((kpi) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: KpiCard(metric: kpi),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMainGrid(SalesDashboardSummary data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 10,
          child: PipelineFunnelCard(
            stages: data.pipelineStages,
            segments: data.clientSegments,
          ),
        ),
        const SizedBox(width: 18.0),
        Expanded(
          flex: 13,
          child: Column(
            children: [
              RecentProposalsList(
                proposals: data.recentProposals,
                onSeeAll: () {},
              ),
              const SizedBox(height: 18.0),
              ExpiringContractsList(
                contracts: data.expiringContracts,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
