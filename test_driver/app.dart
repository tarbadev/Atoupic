import 'package:flutter_driver/driver_extension.dart';
import 'package:atoupic/main.dart' as app;

void main() async {
  enableFlutterDriverExtension();

  await app.main();
}