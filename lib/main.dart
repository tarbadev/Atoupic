import 'package:atoupic/ui/application_injector.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getApplicationInjector().configure();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeLeft);

  Flame.images.loadAll(<String>[
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

  runApp(AtoupicApp());
}
