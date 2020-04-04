import 'base_view_driver.dart';
import 'take_or_pass_dialog_driver.dart';

class InGameViewDriver extends BaseViewDriver {
  InGameViewDriver(driver) : super(driver);

  Future<bool> get isVisible async => await widgetExists('InGame__Container');

  TakeOrPassDialogDriver get takeOrPassDialog => TakeOrPassDialogDriver(driver);
  ScoreDriver get score => ScoreDriver(driver);
}

class ScoreDriver extends BaseViewDriver {
  ScoreDriver(driver) : super(driver);

  Future<bool> get isVisible async => await widgetExists('Score');

  Future<int> get us async => int.parse(await getTextByKey('Score__Us'));

  Future<int> get them async => int.parse(await getTextByKey('Score__Them'));
}