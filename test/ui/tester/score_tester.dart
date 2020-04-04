import 'base_view_tester.dart';

class ScoreTester extends BaseViewTester {
  ScoreTester(tester) : super(tester);

  bool get isVisible => widgetExists('Score');

  int get us => int.parse(getTextByKey('Score__Us'));

  int get them => int.parse(getTextByKey('Score__Them'));
}