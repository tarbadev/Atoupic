import 'package:flutter/material.dart';

import 'base_view_tester.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeViewTester extends BaseViewTester {
  HomeViewTester(tester): super(tester);

  bool get isVisible => widgetExists('Home__SoloButton');
  Future<void> tapOnSolo() async => await tapOnButtonByWidgetAndText(RaisedButton, 'Solo');
}