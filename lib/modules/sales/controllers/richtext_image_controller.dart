import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/richtext_image.dart';
import 'package:centrow_sales/modules/sales/repositories/richtext_image_repository.dart';

class RichtextImageController {
  final RichtextImageRepository _repository;

  RichtextImageController(this._repository);

  static const _pageSize = 30;

  bool _isDisposed = false;
  int _page = 1;
  int _total = 0;
  String _keyword = '';

  final _imagesState = signal<UiState<List<RichtextImage>>>(const UiInitial());
  ReadonlySignal<UiState<List<RichtextImage>>> get imagesState => _imagesState;

  final _isUploading = signal<bool>(false);
  ReadonlySignal<bool> get isUploading => _isUploading;

  final _isLoadingMore = signal<bool>(false);
  ReadonlySignal<bool> get isLoadingMore => _isLoadingMore;

  final _hasMore = signal<bool>(false);
  ReadonlySignal<bool> get hasMore => _hasMore;

  final _actionError = signal<String?>(null);
  ReadonlySignal<String?> get actionError => _actionError;

  Future<void> loadImages({String keyword = ''}) async {
    _keyword = keyword;
    _page = 1;
    _imagesState.value = const UiLoading();

    final result = await _repository.getImages(
      keyword: _keyword,
      page: _page,
      pageSize: _pageSize,
    );
    if (_isDisposed) return;

    switch (result) {
      case Ok(:final value):
        _total = value.total;
        _imagesState.value = UiSuccess<List<RichtextImage>>(value.items);
        _hasMore.value = value.items.length < _total;
      case Err(:final failure):
        _imagesState.value = UiFailure<List<RichtextImage>>(failure);
        _hasMore.value = false;
    }
  }

  Future<void> loadMore() async {
    final current = _imagesState.value;
    if (current is! UiSuccess<List<RichtextImage>>) return;
    if (_isLoadingMore.value || !_hasMore.value) return;

    _isLoadingMore.value = true;
    final result = await _repository.getImages(
      keyword: _keyword,
      page: _page + 1,
      pageSize: _pageSize,
    );
    if (_isDisposed) return;

    switch (result) {
      case Ok(:final value):
        _page += 1;
        _total = value.total;
        final merged = [...current.data, ...value.items];
        _imagesState.value = UiSuccess<List<RichtextImage>>(merged);
        _hasMore.value = merged.length < _total && value.items.isNotEmpty;
      case Err(:final failure):
        _actionError.value = failure.message;
    }
    _isLoadingMore.value = false;
  }

  Future<RichtextImage?> uploadImage(String filePath) async {
    _isUploading.value = true;
    _actionError.value = null;

    final result = await _repository.uploadImage(filePath);
    if (_isDisposed) return null;

    RichtextImage? uploaded;
    switch (result) {
      case Ok(:final value):
        uploaded = value;
        final current = _imagesState.value;
        final existing = current is UiSuccess<List<RichtextImage>>
            ? current.data
            : const <RichtextImage>[];
        _total += 1;
        _imagesState.value = UiSuccess<List<RichtextImage>>([
          value,
          ...existing,
        ]);
      case Err(:final failure):
        _actionError.value = failure.message;
    }

    _isUploading.value = false;
    return uploaded;
  }

  Future<void> deleteImage(String imageId) async {
    final result = await _repository.deleteImage(imageId);
    if (_isDisposed) return;

    switch (result) {
      case Ok():
        final current = _imagesState.value;
        if (current is UiSuccess<List<RichtextImage>>) {
          _total = _total > 0 ? _total - 1 : 0;
          _imagesState.value = UiSuccess<List<RichtextImage>>(
            current.data.where((i) => i.id != imageId).toList(),
          );
        }
      case Err(:final failure):
        _actionError.value = failure.message;
    }
  }

  void clearActionError() {
    _actionError.value = null;
  }

  void dispose() {
    _isDisposed = true;
    _imagesState.dispose();
    _isUploading.dispose();
    _isLoadingMore.dispose();
    _hasMore.dispose();
    _actionError.dispose();
  }
}
