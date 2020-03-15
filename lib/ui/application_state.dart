import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/entity/score_display.dart';

class ApplicationState {
  final bool showTakeOrPassDialog;
  final AtoupicView currentView;
  final Player realPlayer;
  final Turn currentTurn;
  final ScoreDisplay score;

  ApplicationState(
    this.showTakeOrPassDialog,
    this.currentView,
    this.realPlayer,
    this.currentTurn,
    this.score,
  );

  factory ApplicationState.initial() => ApplicationState(
        false,
        AtoupicView.Home,
        null,
        null,
        ScoreDisplay(0, 0),
      );
}