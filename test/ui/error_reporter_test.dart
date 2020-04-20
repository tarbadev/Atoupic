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
    final appName = 'myTestAppName';
    final version = '1.2.3';
    final buildNumber = '1234567890';

    final baseOS = 'baseOS';
    final codename = 'codename';
    final incremental = 'incremental';
    final previewSdkInt = 12;
    final release = 'release';
    final sdkInt = 11;
    final securityPatch = 'securityPatch';

    final androidVersion = <String, dynamic>{
      'baseOS': baseOS,
      'codename': codename,
      'incremental': incremental,
      'previewSdkInt': previewSdkInt,
      'release': release,
      'sdkInt': sdkInt,
      'securityPatch': securityPatch,
    };
    final board = 'board';
    final bootloader = 'bootloader';
    final brand = 'brand';
    final device = 'device';
    final display = 'display';
    final fingerprint = 'fingerprint';
    final hardware = 'hardware';
    final host = 'host';
    final id = 'id';
    final manufacturer = 'manufacturer';
    final model = 'model';
    final product = 'product';
    final supported32BitAbis = ['supported32BitAbis'];
    final supported64BitAbis = ['supported64BitAbis'];
    final supportedAbis = ['supportedAbis'];
    final tags = 'tags';
    final type = 'type';
    final isPhysicalDevice = false;
    final androidId = 'androidId';
    final systemFeatures = ['systemFeatures'];

    ErrorReporter errorReporter;

    setUp(() {
      errorReporter = ErrorReporter(Mocks.sentryClient);

      const MethodChannel('plugins.flutter.io/package_info')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{
            'appName': appName,
            'version': version,
            'buildNumber': buildNumber,
          };
        }
        return null;
      });

      const MethodChannel('plugins.flutter.io/device_info')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAndroidDeviceInfo') {
          return <String, dynamic>{
            'version': androidVersion,
            'board': board,
            'bootloader': bootloader,
            'brand': brand,
            'device': device,
            'display': display,
            'fingerprint': fingerprint,
            'hardware': hardware,
            'host': host,
            'id': id,
            'manufacturer': manufacturer,
            'model': model,
            'product': product,
            'supported32BitAbis': supported32BitAbis,
            'supported64BitAbis': supported64BitAbis,
            'supportedAbis': supportedAbis,
            'tags': tags,
            'type': type,
            'isPhysicalDevice': isPhysicalDevice,
            'androidId': androidId,
            'systemFeatures': systemFeatures,
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
        release: '$appName@$version+$buildNumber',
        environment: 'internaltest',
        extra: <String, dynamic>{
          'version.baseOS': baseOS,
          'version.codename': codename,
          'version.incremental': incremental,
          'version.previewSdkInt': previewSdkInt,
          'version.release': release,
          'version.sdkInt': sdkInt,
          'version.securityPatch': securityPatch,
          'board': board,
          'bootloader': bootloader,
          'brand': brand,
          'device': device,
          'display': display,
          'fingerprint': fingerprint,
          'hardware': hardware,
          'host': host,
          'id': id,
          'manufacturer': manufacturer,
          'model': model,
          'product': product,
          'supported32BitAbis': supported32BitAbis,
          'supported64BitAbis': supported64BitAbis,
          'supportedAbis': supportedAbis,
          'tags': tags,
          'type': type,
          'isPhysicalDevice': isPhysicalDevice,
          'androidId': androidId,
          'systemFeatures': systemFeatures,
        },
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
//      expect(actualEvent.contexts, expectedEvent.contexts);
      expect(actualEvent.breadcrumbs, expectedEvent.breadcrumbs);
    });
  });
}
