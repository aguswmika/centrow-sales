import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/custom_tiptap_toolbar.dart';
import 'package:centrow_sales/modules/sales/views/widgets/webview_tiptap_editor.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProposalDocumentPage extends StatefulWidget {
  final String proposalId;
  final Proposal? initialProposal;

  const ProposalDocumentPage({
    super.key,
    required this.proposalId,
    this.initialProposal,
  });

  @override
  State<ProposalDocumentPage> createState() => _ProposalDocumentPageState();
}

class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
  late final _controller = getIt<ProposalDocumentController>();
  WebViewController? _webViewController;
  TiptapState? _tiptapState;
  Proposal? _proposal;

  bool get canEditDocument => _proposal?.status.canEditDocument ?? true;

  @override
  void initState() {
    super.initState();
    _proposal = widget.initialProposal;
    _controller.loadDocument(widget.proposalId);
    if (_proposal == null) {
      _loadProposal();
    }
  }

  Future<void> _loadProposal() async {
    final repo = getIt<ProposalRepository>();
    final result = await repo.getProposalById(widget.proposalId);
    if (mounted && result is Ok<Proposal>) {
      setState(() {
        _proposal = result.value;
      });
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
                  if (canEditDocument) ...[
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
                ],
              ),
            ),
            if (!canEditDocument && _proposal != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0x24BC7B43),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0x4DBC7B43),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 20.0,
                      color: Color(0xFF92580F),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Proposal ini berstatus ${_proposal!.status.displayName}. Dokumen hanya dapat dibaca dan tidak dapat diubah.',
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          color: const Color(0xFF92580F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
            if (canEditDocument &&
                _webViewController != null &&
                _tiptapState != null) ...[
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
            ],
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: canEditDocument
                      ? Radius.zero
                      : const Radius.circular(12),
                  bottom: const Radius.circular(12),
                ),
                child: WebviewTiptapEditor(
                  initialJson: doc.content,
                  isEditable: canEditDocument,
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
