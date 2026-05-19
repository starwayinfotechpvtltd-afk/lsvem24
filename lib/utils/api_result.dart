class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final ApiErrorType errorType;

  ApiResult.success(this.data)
      : errorMessage = null,
        errorType = ApiErrorType.none;

  ApiResult.failure(this.errorMessage, this.errorType) : data = null;

  bool get isSuccess => errorType == ApiErrorType.none;
}

enum ApiErrorType {
  none,
  noInternet,
  timeout,
  serverError,
  parseError,
  unknown,
}
