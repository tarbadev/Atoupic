import 'base_view_driver.dart';

class HomeViewDriver extends BaseViewDriver {
  HomeViewDriver(driver) : super(driver);

  Future<bool> get isVisible async => await widgetExists('Home__SoloButton');

  Future<void> tapOnStartSolo() async => await tapOnButtonByKey('Home__SoloButton');
}