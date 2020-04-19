import 'dart:async';
import 'dart:isolate';

import 'package:atoupic/ui/application_injector.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/entity/Secrets.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show json;

SentryClient _sentry;

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

dynamic main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initErrorReporting();
  await _initApplication();

  runZoned<Future<Null>>(
    () async => runApp(AtoupicApp()),
    onError: (error, stackTrace) async => await reportError(error, stackTrace),
  );
}

Future<Null> reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }

  print('Reporting to Sentry.io...');

  final SentryResponse response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

_initErrorReporting() {
  FlutterError.onError =
      (FlutterErrorDetails details) async => await reportError(details.exception, details.stack);
  
  Isolate.current.addErrorListener(
    new RawReceivePort(
      (dynamic pair) async => await reportError(
        (pair as List<String>).first,
        (pair as List<String>).last,
      ),
    ).sendPort,
  );
}

Future<Null> _initApplication() async {
  final secretsJson = json.decode(await rootBundle.loadString('assets/secrets.json'));
  final secrets = Secrets.map(secretsJson);
  _sentry = new SentryClient(dsn: secrets.sentryDsn);
  
  getApplicationInjector().configure();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  await Flame.images.loadAll(<String>[
    'cards/clubs/7.png',
    'cards/clubs/8.png',
    'cards/clubs/9.png',
    'cards/clubs/10.png',
    'cards/clubs/A.png',
    'cards/clubs/J.png',
    'cards/clubs/K.png',
    'cards/clubs/Q.png',
    'cards/diamonds/7.png',
    'cards/diamonds/8.png',
    'cards/diamonds/9.png',
    'cards/diamonds/10.png',
    'cards/diamonds/A.png',
    'cards/diamonds/J.png',
    'cards/diamonds/K.png',
    'cards/diamonds/Q.png',
    'cards/hearts/7.png',
    'cards/hearts/8.png',
    'cards/hearts/9.png',
    'cards/hearts/10.png',
    'cards/hearts/A.png',
    'cards/hearts/J.png',
    'cards/hearts/K.png',
    'cards/hearts/Q.png',
    'cards/spades/7.png',
    'cards/spades/8.png',
    'cards/spades/9.png',
    'cards/spades/10.png',
    'cards/spades/A.png',
    'cards/spades/J.png',
    'cards/spades/K.png',
    'cards/spades/Q.png',
    'cards/BackFace.png',
  ]);
}
