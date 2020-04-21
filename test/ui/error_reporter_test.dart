import 'package:atoupic/ui/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:sentry/sentry.dart';

import '../helper/mock_definition.dart';

class MockPlatform extends Mock implements Platform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorReporter', () {
    final stacktrace = 'Some Stacktrace';
    final error = 'An error happened!';

    ErrorReporter errorReporter;
    Platform mockPlatform;

    group('when in debug mode', () {
      setUp(() {
        mockPlatform = MockPlatform();
        errorReporter = ErrorReporter(Mocks.sentryClient, mockPlatform, true);
      });

      test('it does not call sentry client', () async {
        await errorReporter.report(error, stacktrace);

        verifyZeroInteractions(mockPlatform);
        verifyZeroInteractions(Mocks.sentryClient);
      });
    });

    group('when NOT in debug mode', () {
      final appName = 'myTestAppName';
      final version = '1.2.3';
      final buildNumber = '1234567890';

      void _mockPackageInfo() {
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
      }

      void _verifySentryEvent(Event actualEvent, Event expectedEvent) {
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
        expect(actualEvent.breadcrumbs, expectedEvent.breadcrumbs);

        var actualApp = actualEvent.contexts.app;
        var expectedApp = expectedEvent.contexts.app;
        expect(actualApp.name, expectedApp.name);
        expect(actualApp.version, expectedApp.version);
        expect(actualApp.identifier, expectedApp.identifier);
        expect(actualApp.build, expectedApp.build);
        expect(actualApp.buildType, expectedApp.buildType);
        expect(actualApp.startTime, isNotNull);
        expect(actualApp.deviceAppHash, expectedApp.deviceAppHash);

        var actualDevice = actualEvent.contexts.device;
        var expectedDevice = expectedEvent.contexts.device;
        expect(actualDevice.name, expectedDevice.name);
        expect(actualDevice.family, expectedDevice.family);
        expect(actualDevice.model, expectedDevice.model);
        expect(actualDevice.modelId, expectedDevice.modelId);
        expect(actualDevice.arch, expectedDevice.arch);
        expect(actualDevice.batteryLevel, expectedDevice.batteryLevel);
        expect(actualDevice.orientation, expectedDevice.orientation);
        expect(actualDevice.manufacturer, expectedDevice.manufacturer);
        expect(actualDevice.brand, expectedDevice.brand);
        expect(actualDevice.screenResolution, expectedDevice.screenResolution);
        expect(actualDevice.screenDensity, expectedDevice.screenDensity);
        expect(actualDevice.screenDpi, expectedDevice.screenDpi);
        expect(actualDevice.online, expectedDevice.online);
        expect(actualDevice.charging, expectedDevice.charging);
        expect(actualDevice.lowMemory, expectedDevice.lowMemory);
        expect(actualDevice.simulator, expectedDevice.simulator);
        expect(actualDevice.memorySize, expectedDevice.memorySize);
        expect(actualDevice.freeMemory, expectedDevice.freeMemory);
        expect(actualDevice.usableMemory, expectedDevice.usableMemory);
        expect(actualDevice.storageSize, expectedDevice.storageSize);
        expect(actualDevice.freeStorage, expectedDevice.freeStorage);
        expect(actualDevice.externalStorageSize, expectedDevice.externalStorageSize);
        expect(actualDevice.externalFreeStorage, expectedDevice.externalFreeStorage);
        expect(actualDevice.bootTime, expectedDevice.bootTime);
        expect(actualDevice.timezone, expectedDevice.timezone);

        var actualOperatingSystem = actualEvent.contexts.operatingSystem;
        var expectedOperatingSystem = expectedEvent.contexts.operatingSystem;
        expect(actualOperatingSystem.name, expectedOperatingSystem.name);
        expect(actualOperatingSystem.version, expectedOperatingSystem.version);
        expect(actualOperatingSystem.build, expectedOperatingSystem.build);
        expect(actualOperatingSystem.kernelVersion, expectedOperatingSystem.kernelVersion);
        expect(actualOperatingSystem.rooted, expectedOperatingSystem.rooted);
        expect(actualOperatingSystem.rawDescription, expectedOperatingSystem.rawDescription);
      }

      group('When platform is Android', () {
        final androidVersion = <String, dynamic>{
          'baseOS': 'baseOS',
          'codename': 'codename',
          'incremental': 'incremental',
          'previewSdkInt': 12,
          'release': 'release',
          'sdkInt': 11,
          'securityPatch': 'securityPatch',
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
        final isPhysicalDevice = true;
        final androidId = 'androidId';
        final systemFeatures = ['systemFeatures'];

        setUp(() {
          mockPlatform = MockPlatform();
          errorReporter = ErrorReporter(Mocks.sentryClient, mockPlatform, false);

          _mockPackageInfo();

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

          when(mockPlatform.isIOS).thenReturn(false);
        });

        test('reports error to Sentry', () async {
          final eventId = 'event123';
          final releaseName = '$appName@$version+$buildNumber';
          final expectedEvent = Event(
            exception: error,
            stackTrace: stacktrace,
            release: releaseName,
            environment: 'internaltest',
            extra: <String, dynamic>{
              'version.baseOS': androidVersion['baseOS'],
              'version.codename': androidVersion['codename'],
              'version.incremental': androidVersion['incremental'],
              'version.previewSdkInt': androidVersion['previewSdkInt'],
              'version.release': androidVersion['release'],
              'version.sdkInt': androidVersion['sdkInt'],
              'version.securityPatch': androidVersion['securityPatch'],
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
            contexts: Contexts(
              app: App(
                name: 'Atoupic',
                version: version,
                identifier: releaseName,
                build: buildNumber,
                buildType: 'internaltest',
                deviceAppHash: fingerprint,
              ),
              device: Device(
                name: host,
                modelId: androidId,
                family: product,
                model: model,
                manufacturer: manufacturer,
                brand: brand,
                simulator: !isPhysicalDevice,
                arch: board,
              ),
              operatingSystem: OperatingSystem(
                name: 'Android',
                version: androidVersion['release'],
                kernelVersion: fingerprint,
                build: androidVersion['incremental'],
              ),
            ),
          );

          when(Mocks.sentryClient.capture(event: anyNamed('event')))
              .thenAnswer((_) async => SentryResponse.success(eventId: eventId));
          when(mockPlatform.isAndroid).thenReturn(true);

          await errorReporter.report(error, stacktrace);

          final actualEvent =
              verify(Mocks.sentryClient.capture(event: captureAnyNamed('event'))).captured.single;
          _verifySentryEvent(actualEvent, expectedEvent);
        });
      });

      group('When platform is iOS', () {
        final name = 'name';
        final systemName = 'systemName';
        final systemVersion = 'systemVersion';
        final model = 'model';
        final localizedModel = 'localizedModel';
        final identifierForVendor = 'identifierForVendor';
        final isPhysicalDevice = false;
        final utsname = {
          'sysname': 'sysname',
          'nodename': 'nodename',
          'release': 'release',
          'version': 'version',
          'machine': 'machine',
        };

        setUp(() {
          mockPlatform = MockPlatform();
          errorReporter = ErrorReporter(Mocks.sentryClient, mockPlatform, false);

          _mockPackageInfo();

          const MethodChannel('plugins.flutter.io/device_info')
              .setMockMethodCallHandler((MethodCall methodCall) async {
            if (methodCall.method == 'getIosDeviceInfo') {
              return <String, dynamic>{
                'name': name,
                'systemName': systemName,
                'systemVersion': systemVersion,
                'model': model,
                'localizedModel': localizedModel,
                'identifierForVendor': identifierForVendor,
                'isPhysicalDevice': isPhysicalDevice,
                'utsname': utsname,
              };
            }
            return null;
          });

          when(mockPlatform.isAndroid).thenReturn(false);
        });

        test('reports error to Sentry', () async {
          final eventId = 'event123';
          final releaseName = '$appName@$version+$buildNumber';
          final expectedEvent = Event(
            exception: error,
            stackTrace: stacktrace,
            release: releaseName,
            environment: 'internaltest',
            extra: <String, dynamic>{
              'name': name,
              'systemName': systemName,
              'systemVersion': systemVersion,
              'model': model,
              'localizedModel': localizedModel,
              'identifierForVendor': identifierForVendor,
              'isPhysicalDevice': isPhysicalDevice,
              'utsname.sysname': utsname['sysname'],
              'utsname.nodename': utsname['nodename'],
              'utsname.release': utsname['release'],
              'utsname.version': utsname['version'],
              'utsname.machine': utsname['machine'],
            },
            contexts: Contexts(
              app: App(
                name: 'Atoupic',
                version: version,
                identifier: releaseName,
                build: buildNumber,
                buildType: 'internaltest',
              ),
              device: Device(
                name: name,
                model: model,
                manufacturer: 'Apple',
                brand: 'Apple',
                simulator: !isPhysicalDevice,
                arch: utsname['machine'],
                modelId: identifierForVendor,
              ),
              operatingSystem: OperatingSystem(
                name: systemName,
                version: systemVersion,
                kernelVersion: utsname['version'],
              ),
            ),
          );

          when(Mocks.sentryClient.capture(event: anyNamed('event')))
              .thenAnswer((_) async => SentryResponse.success(eventId: eventId));
          when(mockPlatform.isIOS).thenReturn(true);

          await errorReporter.report(error, stacktrace);

          final actualEvent =
              verify(Mocks.sentryClient.capture(event: captureAnyNamed('event'))).captured.single;
          _verifySentryEvent(actualEvent, expectedEvent);
        });
      });

      group('When platform is unknown', () {
        setUp(() {
          mockPlatform = MockPlatform();
          errorReporter = ErrorReporter(Mocks.sentryClient, mockPlatform, false);

          _mockPackageInfo();

          when(mockPlatform.isAndroid).thenReturn(false);
          when(mockPlatform.isIOS).thenReturn(false);
        });

        test('reports error to Sentry', () async {
          final eventId = 'event123';
          final releaseName = '$appName@$version+$buildNumber';
          final expectedEvent = Event(
            exception: error,
            stackTrace: stacktrace,
            release: releaseName,
            environment: 'internaltest',
            extra: {},
            contexts: Contexts(
              app: App(
                name: 'Atoupic',
                version: version,
                identifier: releaseName,
                build: buildNumber,
                buildType: 'internaltest',
              ),
              device: Device(),
              operatingSystem: OperatingSystem(),
            ),
          );

          when(Mocks.sentryClient.capture(event: anyNamed('event')))
              .thenAnswer((_) async => SentryResponse.success(eventId: eventId));

          await errorReporter.report(error, stacktrace);

          final actualEvent =
              verify(Mocks.sentryClient.capture(event: captureAnyNamed('event'))).captured.single;
          _verifySentryEvent(actualEvent, expectedEvent);
        });
      });
    });
  });
}
