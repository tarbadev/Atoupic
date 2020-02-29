import 'package:flutter/material.dart';

import 'base_view_tester.dart';
import 'package:flutter_test/flutter_test.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester): super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogElement get takeOrPass => TakeOrPassDialogElement(tester);
}

class TakeOrPassDialogElement extends BaseViewTester {
  TakeOrPassDialogElement(tester): super(tester);
  Finder get _passButtonFinder => find.byKey(Key('TakeOrPassDialog__PassButton'));

  bool get isVisible => widgetExists('TakeOrPassDialog');

  Future<void> tapOnPass() async => await tester.tap(_passButtonFinder);
}