import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';

class ApplicationState {
  final bool showTakeOrPassDialog;
  final AtoupicView currentView;
  final Player realPlayer;
  final GameContext gameContext;

  ApplicationState(
    this.showTakeOrPassDialog,
    this.currentView,
    this.realPlayer,
    this.gameContext,
  );

  factory ApplicationState.initial() => ApplicationState(
        false,
        AtoupicView.Home,
        null,
        null,
      );
}
