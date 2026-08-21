import 'package:centrow_sales/shared/error/failure.dart';

sealed class UiState<T> {
  const UiState();

  bool get isInitial => this is UiInitial<T>;
  bool get isLoading => this is UiLoading<T>;
  bool get isSuccess => this is UiSuccess<T>;
  bool get isFailure => this is UiFailure<T>;

  T? get dataOrNull => switch (this) {
    UiSuccess(:final data) => data,
    _ => null,
  };

  Failure? get failureOrNull => switch (this) {
    UiFailure(:final failure) => failure,
    _ => null,
  };
}

final class UiInitial<T> extends UiState<T> {
  const UiInitial();

  @override
  String toString() => 'UiInitial<$T>()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiInitial<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading();

  @override
  String toString() => 'UiLoading<$T>()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiLoading<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class UiSuccess<T> extends UiState<T> {
  final T data;

  const UiSuccess(this.data);

  @override
  String toString() => 'UiSuccess<$T>($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

final class UiFailure<T> extends UiState<T> {
  final Failure failure;

  const UiFailure(this.failure);

  @override
  String toString() => 'UiFailure<$T>($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}
