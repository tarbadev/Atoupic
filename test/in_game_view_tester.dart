import 'package:atoupic/application/domain/entity/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogElement get takeOrPass => TakeOrPassDialogElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class TakeOrPassDialogElement extends BaseViewTester {
  TakeOrPassDialogElement(tester) : super(tester);

  Finder get _passButtonFinder =>
      find.byKey(Key('TakeOrPassDialog__PassButton'));

  Finder get _takeButtonFinder =>
      find.byKey(Key('TakeOrPassDialog__TakeButton'));

  bool get isVisible => widgetExists('TakeOrPassDialog');

  List<CardColor> get colorChoices => (tester
          .widget(find.byKey(Key('TakeOrPassDialog__ColorChoices'))) as Row)
      .children
      .map((container) =>
          (((container as Container).child as RaisedButton).child as Text).data)
      .map((symbol) => CardColor.values
          .firstWhere((cardColor) => cardColor.symbol == symbol))
      .toList();

  Future<void> tapOnPass() async => await tester.tap(_passButtonFinder);

  Future<void> tapOnTake() async => await tester.tap(_takeButtonFinder);
}
