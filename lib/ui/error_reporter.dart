import 'package:sentry/sentry.dart';

class ErrorReporter {
  final SentryClient _sentryClient;

  ErrorReporter(this._sentryClient);

  Future report(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    print('Reporting to Sentry.io...');

    final SentryResponse response = await _sentryClient.capture(
      event: Event(
        exception: error,
        stackTrace: stackTrace,
      ),
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }
}
