import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';
import 'package:platform/platform.dart';

class ErrorReporter {
  final SentryClient _sentryClient;
  final Platform _platform;
  final bool isInDebugMode;
  static final DateTime _startTime = DateTime.now();

  ErrorReporter(this._sentryClient, this._platform, this.isInDebugMode);

  Future report(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    if (isInDebugMode) {
      print(stackTrace);
      print('In dev mode. Not sending report to Sentry.io.');
      return;
    }

    print('Reporting to Sentry.io...');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final release = '${packageInfo.appName}@${packageInfo.version}+${packageInfo.buildNumber}';

    var platformDeviceInfo = await _getPlatformDeviceInfo();

    final SentryResponse response = await _sentryClient.capture(
      event: Event(
        exception: error,
        stackTrace: stackTrace,
        release: release,
        environment: 'internaltest',
        contexts: Contexts(
          app: _getAppContext(platformDeviceInfo, packageInfo, release),
          device: _getDeviceContext(platformDeviceInfo),
          operatingSystem: _getOperatingSystemContext(platformDeviceInfo),
        ),
        extra: _getExtras(platformDeviceInfo),
      ),
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }

  App _getAppContext(dynamic deviceInfo, PackageInfo packageInfo, String release) {
    var deviceAppHash;

    if (deviceInfo is AndroidDeviceInfo) {
      deviceAppHash = deviceInfo.fingerprint;
    }

    return App(
      name: 'Atoupic',
      version: packageInfo.version,
      identifier: release,
      build: packageInfo.buildNumber,
      buildType: 'internaltest',
      startTime: _startTime,
      deviceAppHash: deviceAppHash,
    );
  }

  Device _getDeviceContext(dynamic deviceInfo) {
    if (deviceInfo is AndroidDeviceInfo) {
      return Device(
        name: deviceInfo.host,
        modelId: deviceInfo.androidId,
        family: deviceInfo.product,
        model: deviceInfo.model,
        manufacturer: deviceInfo.manufacturer,
        brand: deviceInfo.brand,
        simulator: !deviceInfo.isPhysicalDevice,
        arch: deviceInfo.board,
      );
    } else if (deviceInfo is IosDeviceInfo) {
      return Device(
        name: deviceInfo.name,
        model: deviceInfo.model,
        manufacturer: 'Apple',
        brand: 'Apple',
        simulator: !deviceInfo.isPhysicalDevice,
        modelId: deviceInfo.identifierForVendor,
        arch: deviceInfo.utsname.machine,
      );
    } else {
      return Device();
    }
  }

  Map<String, dynamic> _getExtras(dynamic deviceInfo) {
    if (deviceInfo is AndroidDeviceInfo) {
      return {
        'version.baseOS': deviceInfo.version.baseOS,
        'version.codename': deviceInfo.version.codename,
        'version.incremental': deviceInfo.version.incremental,
        'version.previewSdkInt': deviceInfo.version.previewSdkInt,
        'version.release': deviceInfo.version.release,
        'version.sdkInt': deviceInfo.version.sdkInt,
        'version.securityPatch': deviceInfo.version.securityPatch,
        'board': deviceInfo.board,
        'bootloader': deviceInfo.bootloader,
        'brand': deviceInfo.brand,
        'device': deviceInfo.device,
        'display': deviceInfo.display,
        'fingerprint': deviceInfo.fingerprint,
        'hardware': deviceInfo.hardware,
        'host': deviceInfo.host,
        'id': deviceInfo.id,
        'manufacturer': deviceInfo.manufacturer,
        'model': deviceInfo.model,
        'product': deviceInfo.product,
        'supported32BitAbis': deviceInfo.supported32BitAbis,
        'supported64BitAbis': deviceInfo.supported64BitAbis,
        'supportedAbis': deviceInfo.supportedAbis,
        'tags': deviceInfo.tags,
        'type': deviceInfo.type,
        'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        'androidId': deviceInfo.androidId,
        'systemFeatures': deviceInfo.systemFeatures,
      };
    } else if (deviceInfo is IosDeviceInfo) {
      return {
        'name': deviceInfo.name,
        'systemName': deviceInfo.systemName,
        'systemVersion': deviceInfo.systemVersion,
        'model': deviceInfo.model,
        'localizedModel': deviceInfo.localizedModel,
        'identifierForVendor': deviceInfo.identifierForVendor,
        'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        'utsname.sysname': deviceInfo.utsname.sysname,
        'utsname.nodename': deviceInfo.utsname.nodename,
        'utsname.release': deviceInfo.utsname.release,
        'utsname.version': deviceInfo.utsname.version,
        'utsname.machine': deviceInfo.utsname.machine,
      };
    } else {
      return {};
    }
  }

  OperatingSystem _getOperatingSystemContext(dynamic platformDeviceInfo) {
    if (platformDeviceInfo is AndroidDeviceInfo) {
      return OperatingSystem(
        name: 'Android',
        version: platformDeviceInfo.version.release,
        kernelVersion: platformDeviceInfo.fingerprint,
        build: platformDeviceInfo.version.incremental,
      );
    } else if (platformDeviceInfo is IosDeviceInfo) {
      return OperatingSystem(
        name: platformDeviceInfo.systemName,
        version: platformDeviceInfo.systemVersion,
        kernelVersion: platformDeviceInfo.utsname.version,
      );
    }

    return OperatingSystem();
  }

  Future<dynamic> _getPlatformDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (_platform.isAndroid) {
      return await deviceInfo.androidInfo;
    } else if (_platform.isIOS) {
      return await deviceInfo.iosInfo;
    }
  }
}
