import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';
import 'package:centrow_sales/modules/sales/views/widgets/custom_tiptap_toolbar.dart';
import 'package:centrow_sales/modules/sales/views/widgets/webview_tiptap_editor.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProposalDocumentPage extends StatefulWidget {
  final String proposalId;

  const ProposalDocumentPage({super.key, required this.proposalId});

  @override
  State<ProposalDocumentPage> createState() => _ProposalDocumentPageState();
}

class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
  late final _controller = getIt<ProposalDocumentController>();
  WebViewController? _webViewController;
  TiptapState? _tiptapState;

  @override
  void initState() {
    super.initState();
    _controller.loadDocument(widget.proposalId);
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
        child: Column(
          children: [
            // Custom Header
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
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/proposals');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dokumen Proposal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'Simpan',
                    isFullWidth: false,
                    onPressed: () async {
                      if (_tiptapState != null) {
                        final success = await _controller.saveDocument(
                          widget.proposalId,
                          _tiptapState!.json,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dokumen berhasil disimpan'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  return switch (_controller.state.value) {
                    UiInitial() || UiLoading() => const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                    UiFailure(:final failure) => ErrorView(
                      message: failure.message,
                      onRetry: () =>
                          _controller.loadDocument(widget.proposalId),
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

  Widget _buildEditorContent(ProposalDocument doc) {
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
            if (_webViewController != null && _tiptapState != null)
              CustomTiptapToolbar(
                controller: _webViewController!,
                state: _tiptapState!,
                placeholders: doc.placeholders,
              ),
            const Divider(
              height: 1,
              color: AppColors.border,
              indent: 0,
              endIndent: 0,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: WebviewTiptapEditor(
                  initialJson: doc.content,
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
