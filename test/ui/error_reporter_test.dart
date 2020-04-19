import 'package:atoupic/ui/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentry/sentry.dart';

import '../helper/mock_definition.dart';

void main() {
  group('ErrorReporter', () {
    final stacktrace = 'Some Stacktrace';
    final error = 'An error happened!';
    ErrorReporter errorReporter;

    setUp(() {
      errorReporter = ErrorReporter(Mocks.sentryClient);
    });

    test('reports error to Sentry', () async {
      final eventId = 'event123';

      when(Mocks.sentryClient.captureException(exception: anyNamed('exception'), stackTrace: anyNamed('stackTrace')))
          .thenAnswer((_) async => SentryResponse.success(eventId: eventId));

      await errorReporter.report(error, stacktrace);

      verify(Mocks.sentryClient.captureException(exception: error, stackTrace: stacktrace));
    });
  });
}
