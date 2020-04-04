import 'package:atoupic/domain/entity/card.dart';

import 'base_view_driver.dart';

class TakeOrPassDialogDriver extends BaseViewDriver {
  TakeOrPassDialogDriver(driver) : super(driver);

  Future<bool> get isVisible async => await widgetExists('TakeOrPassDialog');

  Future<List<CardColor>> get colorChoices async {
    List<CardColor> colors = [];
    try {
      var index = 0;
      do {
        var symbol = await getTextByKey('TakeOrPassDialog__ColorChoices__${index++}');
        colors.add(CardColor.values.firstWhere((cardColor) => cardColor.symbol == symbol));
      } while (true);
    } catch (_) {}

    return colors;
  }

  Future<void> tapOnPass() async => await tapOnButtonByKey('TakeOrPassDialog__PassButton');

  Future<void> tapOnTake() async => await tapOnButtonByKey('TakeOrPassDialog__TakeButton');

  Future<void> tapOnColorChoice(CardColor cardColor) async {
    return await tapOnButtonByText(cardColor.symbol);
  }
}
