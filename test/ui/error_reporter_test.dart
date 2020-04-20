import 'package:atoupic/ui/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentry/sentry.dart';

import '../helper/mock_definition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorReporter', () {
    final stacktrace = 'Some Stacktrace';
    final error = 'An error happened!';
    final packageName = 'some.package.name';
    final appName = 'myTestAppName';
    final version = '1.2.3';
    final buildNumber = '1234567890';
    ErrorReporter errorReporter;

    setUp(() {
      errorReporter = ErrorReporter(Mocks.sentryClient);

      const MethodChannel('plugins.flutter.io/package_info')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{
            'appName': appName,
            'packageName': packageName,
            'version': version,
            'buildNumber': buildNumber
          };
        }
        return null;
      });
    });

    test('reports error to Sentry', () async {
      final eventId = 'event123';
      final expectedEvent = Event(
        exception: error,
        stackTrace: stacktrace,
        release: '$packageName.$appName@$version+$buildNumber',
        environment: 'internaltest',
      );

      when(Mocks.sentryClient.capture(event: anyNamed('event')))
          .thenAnswer((_) async => SentryResponse.success(eventId: eventId));

      await errorReporter.report(error, stacktrace);

      final actualEvent =
          verify(Mocks.sentryClient.capture(event: captureAnyNamed('event'))).captured.single;
      expect(actualEvent.loggerName, expectedEvent.loggerName);
      expect(actualEvent.serverName, expectedEvent.serverName);
      expect(actualEvent.release, expectedEvent.release);
      expect(actualEvent.environment, expectedEvent.environment);
      expect(actualEvent.message, expectedEvent.message);
      expect(actualEvent.transaction, expectedEvent.transaction);
      expect(actualEvent.exception, expectedEvent.exception);
      expect(actualEvent.stackTrace, expectedEvent.stackTrace);
      expect(actualEvent.level, expectedEvent.level);
      expect(actualEvent.culprit, expectedEvent.culprit);
      expect(actualEvent.tags, expectedEvent.tags);
      expect(actualEvent.extra, expectedEvent.extra);
      expect(actualEvent.fingerprint, expectedEvent.fingerprint);
      expect(actualEvent.userContext, expectedEvent.userContext);
      expect(actualEvent.contexts, expectedEvent.contexts);
      expect(actualEvent.breadcrumbs, expectedEvent.breadcrumbs);
    });
  });
}
