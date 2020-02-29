import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';

class ApplicationState {
  final bool showTakeOrPassDialog;
  final AtoupicView currentView;
  final Card takeOrPassCard;
  final Player realPlayer;

  ApplicationState(
    this.showTakeOrPassDialog,
    this.currentView,
    this.takeOrPassCard,
    this.realPlayer,
  );

  factory ApplicationState.initial() => ApplicationState(
        false,
        AtoupicView.Home,
        null,
        null,
      );
}
