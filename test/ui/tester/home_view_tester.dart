import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class HomeViewTester extends BaseViewTester {
  HomeViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('Home__SoloButton');

  Future<void> tapOnSolo() async =>
      await tapOnButtonByKey('Home__SoloButton');
}
