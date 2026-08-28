import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_master_list.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_form_bottom_sheet.dart'
    as centrow_sales_bs;

class ProposalPage extends StatefulWidget {
  final ProposalController? controller;
  final String? initialProposalId;

  const ProposalPage({super.key, this.controller, this.initialProposalId});

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  late final ProposalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<ProposalController>();
    _controller.loadProposals().then((_) {
      if (widget.initialProposalId != null) {
        _controller.selectProposal(widget.initialProposalId!);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final state = _controller.proposalsState.value;

            return switch (state) {
              UiInitial() || UiLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
              UiFailure(:final failure) => ErrorView(
                message: failure.message,
                onRetry: _controller.loadProposals,
              ),
              UiSuccess() => _buildSplitContent(context),
            };
          },
        ),
      ),
    );
  }

  Widget _buildSplitContent(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 720;
    final proposals = _controller.filteredProposals.value;
    final selectedProp = _controller.selectedProposal.value;
    final selectedId = _controller.selectedProposalId.value.isNotEmpty
        ? _controller.selectedProposalId.value
        : (selectedProp?.id ?? '');
    final selectedStatus = _controller.selectedStatus.value;
    final query = _controller.searchQuery.value;
    final activePricingTab = _controller.activePricingTab.value;
    final activeDetailTab = _controller.activeDetailTab.value;
    final detailState = _controller.proposalDetailState.value;

    final masterList = ProposalMasterList(
      proposals: proposals,
      selectedProposalId: selectedId,
      selectedStatus: selectedStatus,
      searchQuery: query,
      onSelectProposal: _controller.selectProposal,
      onSelectStatus: _controller.selectStatus,
      onSearchChanged: _controller.setSearchQuery,
      onCreateProposal: () async {
        final result = await showModalBottomSheet<Proposal>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const centrow_sales_bs.ProposalFormBottomSheet(),
        );
        if (result != null && context.mounted) {
          await _controller.loadProposals(isRefresh: true);
          await _controller.selectProposal(result.id);
        }
      },
      onRefresh: () => _controller.loadProposals(isRefresh: true),
    );

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 360.0, child: masterList),
          const VerticalDivider(
            width: 1.5,
            thickness: 1.5,
            color: AppColors.border,
          ),
          Expanded(
            child: ProposalDetailPane(
              proposal: selectedProp,
              detailState: detailState,
              activeDetailTab: activeDetailTab,
              onDetailTabChanged: _controller.setDetailTab,
              activePricingTab: activePricingTab,
              onPricingTabChanged: _controller.setActivePricingTab,
              onExportPdf: () {
                showAppToast(
                  context,
                  'Dokumen proposal PDF siap diunduh.',
                  isSuccess: true,
                );
              },
              onEditProposal: () async {
                if (selectedProp == null) return;
                final result = await showModalBottomSheet<Proposal>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => centrow_sales_bs.ProposalFormBottomSheet(
                    initialProposal: selectedProp,
                  ),
                );
                if (result != null && context.mounted) {
                  await _controller.loadProposals(isRefresh: true);
                  await _controller.selectProposal(result.id);
                }
              },
              onOpenCalculator: selectedId.isNotEmpty
                  ? () => context.go('/proposals/$selectedId/pricing')
                  : null,
              onRetry: () => _controller.loadProposalDetail(selectedId),
            ),
          ),
        ],
      );
    }

    return masterList;
  }
}
