import 'dart:async';
import 'dart:isolate';

import 'package:atoupic/ui/application_injector.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/error_reporter.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

dynamic main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initApplication();

  ErrorReporter errorReporter = kiwi.Container().resolve();
  FlutterError.onError =
      (FlutterErrorDetails details) async => Zone.current.handleUncaughtError(details.exception, details.stack);

  Isolate.current.addErrorListener(
    new RawReceivePort(
          (dynamic pair) async => errorReporter.report(
          (pair as List<String>).first,
          (pair as List<String>).last,
        ),
    ).sendPort,
  );

  runZoned<Future<Null>>(
    () async => runApp(AtoupicApp()),
    onError: (error, stackTrace) async => errorReporter.report(error, stackTrace),
  );
}

Future<Null> _initApplication() async {
  await getApplicationInjector().configure();

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
