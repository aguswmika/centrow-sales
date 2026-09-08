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
import 'package:centrow_sales/modules/sales/controllers/contract_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_master_list.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_form_bottom_sheet.dart';

class ContractPage extends StatefulWidget {
  final ContractController? controller;
  final String? initialContractId;

  const ContractPage({super.key, this.controller, this.initialContractId});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  late final ContractController _controller;
  late final ContractDocumentController _documentController;
  late final void Function() _pdfEffect;

  @override
  void didUpdateWidget(ContractPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContractId != null &&
        widget.initialContractId != oldWidget.initialContractId) {
      _controller.loadContracts(isRefresh: true).then((_) {
        _controller.selectContract(widget.initialContractId!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<ContractController>();
    _documentController = getIt<ContractDocumentController>();
    _controller.loadContracts().then((_) {
      if (widget.initialContractId != null) {
        _controller.selectContract(widget.initialContractId!);
      }
    });

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
    _controller.dispose();
    super.dispose();
  }

  // Saves PDF bytes to a temp file and opens the native PDF viewer.
  Future<void> _openPdfBytes(List<int> bytes) async {
    final selectedId = _controller.selectedContractId.value;
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/contract_$selectedId.pdf');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            return switch (_controller.contractsState.value) {
              UiInitial() || UiLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
              UiFailure(:final failure) => ErrorView(
                message: failure.message,
                onRetry: _controller.loadContracts,
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
    final contracts = _controller.filteredContracts.value;
    final selectedId = _controller.selectedContractId.value;
    final selectedContract = _controller.selectedContract.value;
    final detailState = _controller.contractDetailState.value;
    final isActionLoading = _controller.actionState.value is UiLoading;

    final masterList = ContractMasterList(
      contracts: contracts,
      selectedContractId: selectedId,
      searchQuery: _controller.searchQuery.value,
      selectedStatus: _controller.selectedStatus.value,
      onSelectContract: _controller.selectContract,
      onSearchChanged: _controller.setSearchQuery,
      onStatusChanged: _controller.selectStatus,
      onRefresh: () => _controller.loadContracts(isRefresh: true),
    );

    if (!isTablet) return masterList;

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
          child: ContractDetailPane(
            contract: selectedContract,
            detailState: detailState,
            isActionLoading: isActionLoading,
            onRetry: selectedId.isNotEmpty
                ? () => _controller.selectContract(selectedId)
                : null,
            onOpenDocument: selectedId.isNotEmpty
                ? () => context.go(
                    '/contracts/$selectedId/document',
                    extra: selectedContract,
                  )
                : null,
            onExportPdf: selectedId.isNotEmpty
                ? () => _documentController.downloadPdf(selectedId)
                : null,
            isExportingPdf: _documentController.pdfState.value is UiLoading,
            onActivate: selectedContract?.status.canActivate == true
                ? () => _handleActivate(selectedContract!)
                : null,
            onSuspend: selectedContract?.status.canSuspend == true
                ? () => _handleSuspend(selectedContract!)
                : null,
            onTerminate: selectedContract?.status.canTerminate == true
                ? () => _handleTerminate(selectedContract!)
                : null,
            onCancel: selectedContract?.status.canCancel == true
                ? () => _handleCancel(selectedContract!)
                : null,
            onEdit: selectedContract?.status.canEdit == true
                ? () => _handleEdit(selectedContract!)
                : null,
            onDelete: selectedContract?.status.canDelete == true
                ? () => _handleDelete(selectedContract!)
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _handleActivate(Contract c) async {
    if (!await _confirm(
      title: 'Aktifkan Kontrak',
      content: 'Aktifkan kontrak ${c.code}?',
      confirmLabel: 'Aktifkan',
    )) {
      return;
    }
    final res = await _controller.activateContract(c.id);
    if (mounted) {
      _feedback(res, ok: 'Kontrak berhasil diaktifkan.');
    }
  }

  Future<void> _handleSuspend(Contract c) async {
    if (!await _confirm(
      title: 'Tangguhkan Kontrak',
      content: 'Tangguhkan kontrak ${c.code}?',
      confirmLabel: 'Tangguhkan',
    )) {
      return;
    }
    final res = await _controller.suspendContract(c.id);
    if (mounted) {
      _feedback(res, ok: 'Kontrak telah ditangguhkan.');
    }
  }

  Future<void> _handleTerminate(Contract c) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminasi Kontrak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan alasan terminasi untuk kontrak ${c.code}:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Kontrak dibatalkan oleh klien',
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.err),
            onPressed: () {
              final text = reasonCtrl.text.trim();
              if (text.isEmpty) {
                showAppToast(
                  ctx,
                  'Alasan terminasi wajib diisi',
                  isError: true,
                );
                return;
              }
              Navigator.of(ctx).pop(text);
            },
            child: const Text('Terminasi'),
          ),
        ],
      ),
    );
    reasonCtrl.dispose();
    if (reason != null && reason.isNotEmpty && mounted) {
      final res = await _controller.terminateContract(c.id, reason);
      if (mounted) {
        _feedback(res, ok: 'Kontrak telah diterminasi.');
      }
    }
  }

  Future<void> _handleCancel(Contract c) async {
    if (!await _confirm(
      title: 'Batalkan Kontrak',
      content:
          'Yakin ingin membatalkan kontrak ${c.code}? Tindakan ini tidak dapat diurungkan.',
      confirmLabel: 'Batalkan Kontrak',
      isDestructive: true,
    )) {
      return;
    }
    final res = await _controller.cancelContract(c.id);
    if (mounted) {
      _feedback(res, ok: 'Kontrak telah dibatalkan.');
    }
  }

  Future<void> _handleEdit(Contract c) async {
    final result = await showModalBottomSheet<Contract>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContractFormBottomSheet(initialContract: c),
    );
    if (result != null && mounted) {
      showAppToast(context, 'Kontrak berhasil diperbarui.', isSuccess: true);
      await _controller.loadContracts(isRefresh: true);
      await _controller.selectContract(c.id);
    }
  }

  Future<void> _handleDelete(Contract c) async {
    if (!await _confirm(
      title: 'Hapus Draf Kontrak',
      content:
          'Yakin ingin menghapus draf kontrak ${c.code}? Tindakan ini tidak dapat diurungkan.',
      confirmLabel: 'Hapus Kontrak',
      isDestructive: true,
    )) {
      return;
    }
    final res = await _controller.deleteContract(c.id);
    if (mounted) {
      if (res is Ok) {
        showAppToast(context, 'Kontrak telah dihapus.', isSuccess: true);
      } else if (res is Err) {
        showAppToast(context, res.failure.message, isError: true);
      }
    }
  }

  void _feedback(Result<dynamic> res, {required String ok}) {
    if (res is Ok) {
      showAppToast(context, ok, isSuccess: true);
    } else if (res is Err<dynamic>) {
      showAppToast(context, res.failure.message, isError: true);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.err)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }
}
