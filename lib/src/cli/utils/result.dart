/// Represents the result an action.
enum ResultState {
  /// No result.
  empty,

  /// Successful execution.
  success,

  /// Error occurred.
  error
}

/// A data class that can be used to either return data or error as a result
/// of a process/action.
class Result<T> {
  /// Represents the state of this result.
  final ResultState state;

  final T? _data;

  final String? _error;

  /// Exception that occurred while performing the action if any.
  final Object? exception;

  /// Stacktrace when an exception occurred if any.
  final StackTrace? stacktrace;

  /// Data that was returned as a result of the action when it succeeded.
  T get data => _data!;

  /// Error that was returned as a result of the action when it failed.
  String get error => _error!;

  /// Returns true if this result is successful.
  bool get isSuccess => state == ResultState.success;

  /// Returns true if this result is an error.
  bool get isError => state == ResultState.error && _error != null;

  /// Returns true if this result is empty.
  bool get isEmpty => state == ResultState.empty;

  /// Constructor that creates an empty result.
  const Result.empty()
      : _data = null,
        _error = null,
        exception = null,
        stacktrace = null,
        state = ResultState.empty;

  /// Constructor that creates a successful result.
  const Result.success([this._data])
      : _error = null,
        exception = null,
        stacktrace = null,
        state = ResultState.success;

  /// Constructor that creates an error result.
  const Result.error(this._error, [this.exception, this.stacktrace])
      : _data = null,
        state = ResultState.error;
}
