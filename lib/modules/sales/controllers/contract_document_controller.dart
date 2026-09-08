import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_document_repository.dart';

class ContractDocumentController {
  final ContractDocumentRepository _repository;

  ContractDocumentController(this._repository);

  final _state = signal<UiState<ContractDocument>>(const UiInitial());
  ReadonlySignal<UiState<ContractDocument>> get state => _state;

  final _pdfState = signal<UiState<List<int>>>(const UiInitial());
  ReadonlySignal<UiState<List<int>>> get pdfState => _pdfState;

  Future<void> loadDocument(
    String contractId, {
    bool fromTemplate = false,
  }) async {
    _state.value = const UiLoading();
    final result = await _repository.getDocument(
      contractId,
      fromTemplate: fromTemplate,
    );
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<bool> saveDocument(
    String contractId,
    Map<String, dynamic> content,
  ) async {
    final result = await _repository.saveDocument(contractId, content);
    return switch (result) {
      Ok() => true,
      Err() => false,
    };
  }

  Future<void> downloadPdf(String contractId) async {
    _pdfState.value = const UiLoading();
    final result = await _repository.downloadPdf(contractId);
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
