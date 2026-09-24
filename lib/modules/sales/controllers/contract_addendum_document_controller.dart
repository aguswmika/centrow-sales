import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_document_repository.dart';

class ContractAddendumDocumentController {
  final ContractAddendumDocumentRepository _repository;

  ContractAddendumDocumentController(this._repository);

  bool _isDisposed = false;

  final _templatesState = signal<UiState<List<AddendumTemplate>>>(
    const UiInitial(),
  );
  ReadonlySignal<UiState<List<AddendumTemplate>>> get templatesState =>
      _templatesState;

  final _state = signal<UiState<ContractAddendumDocument>>(const UiInitial());
  ReadonlySignal<UiState<ContractAddendumDocument>> get state => _state;

  final _saveState = signal<UiState<ContractAddendumDocument>>(
    const UiInitial(),
  );
  ReadonlySignal<UiState<ContractAddendumDocument>> get saveState => _saveState;

  final _pdfState = signal<UiState<List<int>>>(const UiInitial());
  ReadonlySignal<UiState<List<int>>> get pdfState => _pdfState;

  Future<void> loadActiveTemplates() async {
    _templatesState.value = const UiLoading();
    final result = await _repository.getActiveTemplates();
    if (_isDisposed) return;
    _templatesState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> loadDocument(String addendumId, {String? templateId}) async {
    _state.value = const UiLoading();
    final result = await _repository.getDocument(
      addendumId,
      templateId: templateId,
    );
    if (_isDisposed) return;
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<Result<ContractAddendumDocument>> saveDocument(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  }) async {
    _saveState.value = const UiLoading();
    final result = await _repository.saveDocument(
      addendumId,
      content: content,
      templateId: templateId,
    );
    if (_isDisposed) return result;
    _saveState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
    if (result is Ok<ContractAddendumDocument>) {
      _state.value = UiSuccess(result.value);
    }
    return result;
  }

  Future<Result<List<int>>> downloadPdf(
    String addendumId, {
    String? templateId,
  }) async {
    _pdfState.value = const UiLoading();
    final result = await _repository.downloadPdf(
      addendumId,
      templateId: templateId,
    );
    if (_isDisposed) return result;
    _pdfState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
    return result;
  }

  void resetSaveState() {
    if (!_isDisposed) _saveState.value = const UiInitial();
  }

  void resetPdfState() {
    if (!_isDisposed) _pdfState.value = const UiInitial();
  }

  void dispose() {
    _isDisposed = true;
    _templatesState.dispose();
    _state.dispose();
    _saveState.dispose();
    _pdfState.dispose();
  }
}
