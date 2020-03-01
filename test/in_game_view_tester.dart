import 'package:flutter/material.dart';

import 'base_view_tester.dart';
import 'package:flutter_test/flutter_test.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester): super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogElement get takeOrPass => TakeOrPassDialogElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class TakeOrPassDialogElement extends BaseViewTester {
  TakeOrPassDialogElement(tester): super(tester);
  Finder get _passButtonFinder => find.byKey(Key('TakeOrPassDialog__PassButton'));
  Finder get _takeButtonFinder => find.byKey(Key('TakeOrPassDialog__TakeButton'));

  bool get isVisible => widgetExists('TakeOrPassDialog');

  Future<void> tapOnPass() async => await tester.tap(_passButtonFinder);
  Future<void> tapOnTake() async => await tester.tap(_takeButtonFinder);
}