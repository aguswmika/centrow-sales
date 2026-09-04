import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_document_repository.dart';

class ProposalDocumentController {
  final ProposalDocumentRepository _repository;

  ProposalDocumentController(this._repository);

  final _state = signal<UiState<ProposalDocument>>(const UiInitial());
  ReadonlySignal<UiState<ProposalDocument>> get state => _state;

  final _pdfState = signal<UiState<List<int>>>(const UiInitial());
  ReadonlySignal<UiState<List<int>>> get pdfState => _pdfState;

  Future<void> loadDocument(
    String proposalId, {
    bool fromTemplate = false,
  }) async {
    _state.value = const UiLoading();
    final result = await _repository.getDocument(
      proposalId,
      fromTemplate: fromTemplate,
    );
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<bool> saveDocument(
    String proposalId,
    Map<String, dynamic> content,
  ) async {
    final result = await _repository.saveDocument(proposalId, content);
    return switch (result) {
      Ok() => true,
      Err() => false,
    };
  }

  Future<void> downloadPdf(String proposalId) async {
    _pdfState.value = const UiLoading();
    final result = await _repository.downloadPdf(proposalId);
    _pdfState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void resetPdfState() {
    _pdfState.value = const UiInitial();
  }

  void dispose() {
    _pdfState.dispose();
    _state.dispose();
  }
}
