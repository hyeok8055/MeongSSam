sealed class NetworkResult<T> {
  const NetworkResult();
}

final class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);

  final T data;
}

final class NetworkFailure<T> extends NetworkResult<T> {
  const NetworkFailure(this.message);

  final String message;
}
