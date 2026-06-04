/// Thrown when the device has no network or the request cannot reach the server.
class NoInternetException implements Exception {
  final String message;

  const NoInternetException([
    this.message = 'No internet connection. Please check your network and try again.',
  ]);

  @override
  String toString() => message;
}
