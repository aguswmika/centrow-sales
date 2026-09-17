import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/customer_photo.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_photo_repository.dart';

class CustomerPhotoController {
  final CustomerPhotoRepository _repository;

  CustomerPhotoController(this._repository);

  bool _isDisposed = false;

  final _photosState = signal<UiState<List<CustomerPhoto>>>(const UiInitial());
  ReadonlySignal<UiState<List<CustomerPhoto>>> get photosState => _photosState;

  final _isUploading = signal<bool>(false);
  ReadonlySignal<bool> get isUploading => _isUploading;

  final _actionError = signal<String?>(null);
  ReadonlySignal<String?> get actionError => _actionError;

  Future<void> loadPhotos(String customerId) async {
    // Only set loading if not already in success state (to avoid flicker on refresh)
    if (_photosState.value is! UiSuccess) {
      _photosState.value = const UiLoading();
    }
    final result = await _repository.getPhotos(customerId);
    if (_isDisposed) return;
    _photosState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<CustomerPhoto>>(value),
      Err(:final failure) => UiFailure<List<CustomerPhoto>>(failure),
    };
  }

  Future<void> addPhoto(String customerId, String filePath) async {
    _isUploading.value = true;
    _actionError.value = null;

    final result = await _repository.uploadPhoto(customerId, filePath);
    if (_isDisposed) {
      _isUploading.value = false;
      return;
    }

    switch (result) {
      case Ok(:final value):
        // Append the new photo to the current state
        final currentState = _photosState.value;
        if (currentState is UiSuccess<List<CustomerPhoto>>) {
          final updatedList = [...currentState.data, value];
          _photosState.value = UiSuccess(updatedList);
        } else {
          // If state isn't UiSuccess (e.g., was UiInitial/UiFailure), wrap the single photo
          _photosState.value = UiSuccess([value]);
        }
      case Err(:final failure):
        _actionError.value = failure.message;
    }

    _isUploading.value = false;
  }

  Future<void> deletePhoto(String customerId, String photoId) async {
    final result = await _repository.deletePhoto(customerId, photoId);
    if (_isDisposed) return;

    switch (result) {
      case Ok():
        // Remove the photo from the current state only on success
        final currentState = _photosState.value;
        if (currentState is UiSuccess<List<CustomerPhoto>>) {
          final updatedList = currentState.data
              .where((p) => p.id != photoId)
              .toList();
          _photosState.value = UiSuccess(updatedList);
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
    _photosState.dispose();
    _isUploading.dispose();
    _actionError.dispose();
  }
}
