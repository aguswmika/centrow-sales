import 'dart:async';
import 'package:signals/signals.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class SplashController {
  final AuthRepository _authRepository;
  final AuthTokenHolder _tokenHolder;

  SplashController(this._authRepository, [AuthTokenHolder? tokenHolder])
    : _tokenHolder = tokenHolder ?? AuthTokenHolder.instance;

  final _state = signal<UiState<String>>(const UiInitial());
  ReadonlySignal<UiState<String>> get state => _state;

  final _targetRoute = signal<String?>(null);
  ReadonlySignal<String?> get targetRoute => _targetRoute;

  bool _isDisposed = false;

  Future<void> checkSession({
    Duration minDuration = const Duration(milliseconds: 1200),
    Duration verificationTimeout = const Duration(seconds: 4),
  }) async {
    _state.value = const UiLoading();

    final minDelayFuture = Future<void>.delayed(minDuration);

    String destination = '/login';

    if (_tokenHolder.hasToken) {
      try {
        final result = await _authRepository.getMe().timeout(
          verificationTimeout,
          onTimeout: () => const Err(NetworkFailure('Request timeout')),
        );

        switch (result) {
          case Ok(:final value):
            _tokenHolder.user = value;
            destination = '/customers';
          case Err(:final failure):
            if (failure is ServerFailure && failure.statusCode == 401) {
              await _tokenHolder.clear();
              destination = '/login';
            } else {
              // Graceful offline fallback: allow entering with stored session
              destination = '/customers';
            }
        }
      } catch (_) {
        // Unexpected error, fall back to cached session
        destination = '/customers';
      }
    } else {
      destination = '/login';
    }

    await minDelayFuture;

    if (!_isDisposed) {
      _state.value = UiSuccess(destination);
      _targetRoute.value = destination;
    }
  }

  void dispose() {
    _isDisposed = true;
    _state.dispose();
    _targetRoute.dispose();
  }
}
