import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';

import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_document_controller.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_master_list.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_form_bottom_sheet.dart'
    as centrow_sales_bs;

class ProposalPage extends StatefulWidget {
  final ProposalController? controller;
  final ProposalDocumentController? documentController;
  final String? initialProposalId;

  const ProposalPage({
    super.key,
    this.controller,
    this.documentController,
    this.initialProposalId,
  });

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  late final ProposalController _controller;
  late final ProposalDocumentController _documentController;
  late final void Function() _pdfEffect;

  @override
  void didUpdateWidget(ProposalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialProposalId != null &&
        widget.initialProposalId != oldWidget.initialProposalId) {
      _controller.loadProposals(isRefresh: true).then((_) {
        _controller.selectProposal(widget.initialProposalId!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<ProposalController>();
    _documentController =
        widget.documentController ?? getIt<ProposalDocumentController>();
    _controller.loadProposals().then((_) {
      if (widget.initialProposalId != null) {
        _controller.selectProposal(widget.initialProposalId!);
      }
    });
    // Side-effect: open PDF file on success, show snackbar on failure
    _pdfEffect = effect(() {
      final state = _documentController.pdfState.value;
      if (state is UiSuccess<List<int>>) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _openPdfBytes(state.data),
        );
      } else if (state is UiFailure<List<int>>) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure.message)));
            _documentController.resetPdfState();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pdfEffect();
    _documentController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  // Saves PDF bytes to a temp file and opens the native PDF viewer.
  Future<void> _openPdfBytes(List<int> bytes) async {
    final selectedId = _controller.selectedProposalId.value;
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/proposal_$selectedId.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka PDF: $e')));
      }
    } finally {
      _documentController.resetPdfState();
    }
  }

  Future<void> _handleSendProposal(Proposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Proposal'),
        content: Text(
          'Kirim proposal ${proposal.code} ke klien? Kalkulasi harga dan rincian akan dikunci setelah dikirim.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final res = await _controller.sendProposal(proposal.id);
      if (mounted) {
        if (res is Ok) {
          showAppToast(context, 'Proposal berhasil dikirim.', isSuccess: true);
        } else if (res is Err) {
          showAppToast(context, (res as Err).failure.message, isError: true);
        }
      }
    }
  }

  Future<void> _handleAcceptProposal(Proposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terima Proposal'),
        content: Text(
          'Tandai proposal ${proposal.code} sebagai diterima / disetujui oleh klien?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final res = await _controller.acceptProposal(proposal.id);
      if (mounted) {
        if (res is Ok) {
          showAppToast(
            context,
            'Proposal telah diterima klien.',
            isSuccess: true,
          );
        } else if (res is Err) {
          showAppToast(context, (res as Err).failure.message, isError: true);
        }
      }
    }
  }

  Future<void> _handleRejectProposal(Proposal proposal) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tolak Proposal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan alasan penolakan untuk proposal ${proposal.code}:',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Harga di atas anggaran klien',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) {
                  showAppToast(
                    ctx,
                    'Alasan penolakan wajib diisi',
                    isError: true,
                  );
                  return;
                }
                Navigator.of(ctx).pop(text);
              },
              child: const Text('Tolak Proposal'),
            ),
          ],
        ),
      ),
    );
    if (reason != null && reason.isNotEmpty && mounted) {
      final res = await _controller.rejectProposal(proposal.id, reason);
      if (mounted) {
        if (res is Ok) {
          showAppToast(context, 'Proposal ditolak.', isSuccess: true);
        } else if (res is Err) {
          showAppToast(context, (res as Err).failure.message, isError: true);
        }
      }
    }
  }

  Future<void> _handleExpireProposal(Proposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tandai Kedaluwarsa'),
        content: Text('Tandai proposal ${proposal.code} sebagai kedaluwarsa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tandai Kedaluwarsa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final res = await _controller.expireProposal(proposal.id);
      if (mounted) {
        if (res is Ok) {
          showAppToast(
            context,
            'Proposal ditandai kedaluwarsa.',
            isSuccess: true,
          );
        } else if (res is Err) {
          showAppToast(context, (res as Err).failure.message, isError: true);
        }
      }
    }
  }

  Future<void> _handleCancelProposal(Proposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Proposal'),
        content: Text(
          'Yakin ingin membatalkan proposal ${proposal.code}? Tindakan ini tidak dapat diurungkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.err),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Batalkan Proposal'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final res = await _controller.cancelProposal(proposal.id);
      if (mounted) {
        if (res is Ok) {
          showAppToast(context, 'Proposal telah dibatalkan.', isSuccess: true);
        } else if (res is Err) {
          showAppToast(context, (res as Err).failure.message, isError: true);
        }
      }
    }
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
    final isExportingPdf = _documentController.pdfState.value is UiLoading;

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
              onExportPdf: selectedId.isNotEmpty
                  ? () => _documentController.downloadPdf(selectedId)
                  : null,
              isExportingPdf: isExportingPdf,
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
              onReviseProposal: () async {
                if (selectedProp == null) return;
                final result = await showModalBottomSheet<Proposal>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => centrow_sales_bs.ProposalFormBottomSheet(
                    initialProposal: selectedProp,
                    isReviseMode: true,
                  ),
                );
                if (result != null && context.mounted) {
                  await _controller.loadProposals(isRefresh: true);
                  await _controller.selectProposal(result.id);
                }
              },
              onSendProposal: selectedProp != null
                  ? () => _handleSendProposal(selectedProp)
                  : null,
              onAcceptProposal: selectedProp != null
                  ? () => _handleAcceptProposal(selectedProp)
                  : null,
              onRejectProposal: selectedProp != null
                  ? () => _handleRejectProposal(selectedProp)
                  : null,
              onExpireProposal: selectedProp != null
                  ? () => _handleExpireProposal(selectedProp)
                  : null,
              onCancelProposal: selectedProp != null
                  ? () => _handleCancelProposal(selectedProp)
                  : null,
              isActionLoading: _controller.actionState.value is UiLoading,
              onOpenCalculator: (selectedId.isNotEmpty &&
                      (selectedProp?.status.canEditPricing ?? true))
                  ? () => context.go(
                        '/proposals/$selectedId/pricing',
                        extra: selectedProp,
                      )
                  : null,
              onOpenDocument: selectedId.isNotEmpty
                  ? () => context.go(
                        '/proposals/$selectedId/document',
                        extra: selectedProp,
                      )
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
