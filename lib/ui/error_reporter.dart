import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

class ErrorReporter {
  final SentryClient _sentryClient;
  static final DateTime _startTime = DateTime.now();

  ErrorReporter(this._sentryClient);

  Future report(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    print('Reporting to Sentry.io...');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final release = '${packageInfo.appName}@${packageInfo.version}+${packageInfo.buildNumber}';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    final SentryResponse response = await _sentryClient.capture(
      event: Event(
        exception: error,
        stackTrace: stackTrace,
        release: release,
        environment: 'internaltest',
        contexts: Contexts(
          app: App(
            name: 'Atoupic',
            version: packageInfo.version,
            identifier: release,
            build: packageInfo.buildNumber,
            buildType: 'internaltest',
            startTime: _startTime,
            deviceAppHash: androidDeviceInfo.fingerprint,
          ),
          device: Device(
            name: androidDeviceInfo.host,
            modelId: androidDeviceInfo.androidId,
            family: androidDeviceInfo.product,
            model: androidDeviceInfo.device,
            manufacturer: androidDeviceInfo.manufacturer,
            brand: androidDeviceInfo.brand,
            simulator: !androidDeviceInfo.isPhysicalDevice,
            arch: androidDeviceInfo.board,
          ),
        ),
        extra: <String, dynamic>{
          'version.baseOS': androidDeviceInfo.version.baseOS,
          'version.codename': androidDeviceInfo.version.codename,
          'version.incremental': androidDeviceInfo.version.incremental,
          'version.previewSdkInt': androidDeviceInfo.version.previewSdkInt,
          'version.release': androidDeviceInfo.version.release,
          'version.sdkInt': androidDeviceInfo.version.sdkInt,
          'version.securityPatch': androidDeviceInfo.version.securityPatch,
          'board': androidDeviceInfo.board,
          'bootloader': androidDeviceInfo.bootloader,
          'brand': androidDeviceInfo.brand,
          'device': androidDeviceInfo.device,
          'display': androidDeviceInfo.display,
          'fingerprint': androidDeviceInfo.fingerprint,
          'hardware': androidDeviceInfo.hardware,
          'host': androidDeviceInfo.host,
          'id': androidDeviceInfo.id,
          'manufacturer': androidDeviceInfo.manufacturer,
          'model': androidDeviceInfo.model,
          'product': androidDeviceInfo.product,
          'supported32BitAbis': androidDeviceInfo.supported32BitAbis,
          'supported64BitAbis': androidDeviceInfo.supported64BitAbis,
          'supportedAbis': androidDeviceInfo.supportedAbis,
          'tags': androidDeviceInfo.tags,
          'type': androidDeviceInfo.type,
          'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice,
          'androidId': androidDeviceInfo.androidId,
          'systemFeatures': androidDeviceInfo.systemFeatures,
        },
      ),
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }
}
