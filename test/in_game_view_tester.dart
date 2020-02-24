import 'package:flutter/material.dart';

import 'base_view_tester.dart';
import 'package:flutter_test/flutter_test.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester): super(tester);

  bool get isVisible => widgetExists('InGame__Container');
}