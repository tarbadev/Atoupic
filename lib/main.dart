import 'package:atoupic/application/ui/application_injector.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getApplicationInjector().configure();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeLeft);

  runApp(AtoupicApp());
}