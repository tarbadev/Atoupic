import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';

class ApplicationState {
  final bool showTakeOrPassDialog;
  final AtoupicView currentView;
  final Card takeOrPassCard;

  ApplicationState(
    this.showTakeOrPassDialog,
    this.currentView,
    this.takeOrPassCard,
  );

  factory ApplicationState.initial() => ApplicationState(false, AtoupicView.Home, null);
}
