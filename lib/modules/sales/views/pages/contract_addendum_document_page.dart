import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/views/widgets/custom_tiptap_toolbar.dart';
import 'package:centrow_sales/modules/sales/views/widgets/webview_tiptap_editor.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContractAddendumDocumentPage extends StatefulWidget {
  final String contractId;
  final String addendumId;
  final String? initialTemplateId;
  final ContractAddendumDocumentController? controller;

  const ContractAddendumDocumentPage({
    super.key,
    required this.contractId,
    required this.addendumId,
    this.initialTemplateId,
    this.controller,
  });

  @override
  State<ContractAddendumDocumentPage> createState() =>
      _ContractAddendumDocumentPageState();
}

class _ContractAddendumDocumentPageState
    extends State<ContractAddendumDocumentPage> {
  late final ContractAddendumDocumentController _controller;
  late final void Function() _pdfEffect;
  WebViewController? _webViewController;
  TiptapState? _tiptapState;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? getIt<ContractAddendumDocumentController>();
    _controller.loadDocument(
      widget.addendumId,
      templateId: widget.initialTemplateId,
    );

    _pdfEffect = effect(() {
      final state = _controller.pdfState.value;
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
            _controller.resetPdfState();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pdfEffect();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openPdfBytes(List<int> bytes) async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/addendum_${widget.addendumId}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka PDF: $e')));
      }
    } finally {
      _controller.resetPdfState();
    }
  }

  Future<void> _handleSave(ContractAddendumDocument doc) async {
    final content = _tiptapState?.json ?? doc.content;
    final result = await _controller.saveDocument(
      widget.addendumId,
      content: content,
      templateId: widget.initialTemplateId ?? doc.templateId,
    );
    if (mounted) {
      switch (result) {
        case Ok():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokumen addendum berhasil disimpan')),
          );
        case Err(:final failure):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  Future<void> _handleDownloadPdf(ContractAddendumDocument doc) async {
    await _controller.downloadPdf(
      widget.addendumId,
      templateId: widget.initialTemplateId ?? doc.templateId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/contracts');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dokumen Addendum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  SignalBuilder(
                    builder: (context) {
                      final doc = _controller.state.value.dataOrNull;
                      if (doc == null) {
                        return const SizedBox.shrink();
                      }

                      final isPdfLoading =
                          _controller.pdfState.value is UiLoading;
                      final isSaveLoading =
                          _controller.saveState.value is UiLoading;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton.secondary(
                            text: 'Unduh PDF',
                            isFullWidth: false,
                            isLoading: isPdfLoading,
                            icon: const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 18,
                            ),
                            onPressed: () => _handleDownloadPdf(doc),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Simpan',
                            isFullWidth: false,
                            isLoading: isSaveLoading,
                            onPressed: () => _handleSave(doc),
                          ),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  return switch (_controller.state.value) {
                    UiInitial() || UiLoading() => const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                    UiFailure(:final failure) => ErrorView(
                      message: failure.message,
                      onRetry: () => _controller.loadDocument(
                        widget.addendumId,
                        templateId: widget.initialTemplateId,
                      ),
                    ),
                    UiSuccess(:final data) => _buildEditorContent(data),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorContent(ContractAddendumDocument doc) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_webViewController != null && _tiptapState != null) ...[
              CustomTiptapToolbar(
                controller: _webViewController!,
                state: _tiptapState!,
                placeholders: const [],
              ),
              const Divider(
                height: 1,
                color: AppColors.border,
                indent: 0,
                endIndent: 0,
              ),
            ],
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: (_webViewController != null && _tiptapState != null)
                      ? Radius.zero
                      : const Radius.circular(12),
                  bottom: const Radius.circular(12),
                ),
                child: WebviewTiptapEditor(
                  initialJson: doc.content,
                  isEditable: true,
                  onStateChange: (state) {
                    if (mounted) {
                      setState(() {
                        _tiptapState = state;
                      });
                    }
                  },
                  onControllerCreated: (controller) {
                    if (mounted) {
                      setState(() {
                        _webViewController = controller;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
