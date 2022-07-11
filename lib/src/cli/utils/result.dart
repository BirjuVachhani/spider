enum ResultState { empty, success, error }

/// A data class that can be used to either return data or error as a result
/// of a process/action.
class Result<T> {
  final ResultState state;

  final T? _data;

  final String? _error;

  final Object? exception;

  final StackTrace? stacktrace;

  T get data => _data!;

  String get error => _error!;

  bool get isSuccess => state == ResultState.success;

  bool get isError => state == ResultState.error && _error != null;

  bool get isEmpty => state == ResultState.empty;

  const Result.empty()
      : _data = null,
        _error = null,
        exception = null,
        stacktrace = null,
        state = ResultState.empty;

  const Result.success([this._data])
      : _error = null,
        exception = null,
        stacktrace = null,
        state = ResultState.success;

  const Result.error(this._error, [this.exception, this.stacktrace])
      : _data = null,
        state = ResultState.error;
}
