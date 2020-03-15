import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/entity/turn.dart';
import 'package:atoupic/application/domain/entity/turn_result.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:atoupic/application/ui/entity/score_display.dart';

class ApplicationState {
  final bool showTakeOrPassDialog;
  final AtoupicView currentView;
  final Player realPlayer;
  final Turn currentTurn;
  final TurnResult turnResult;

  final ScoreDisplay score;

  ApplicationState(
    this.showTakeOrPassDialog,
    this.currentView,
    this.realPlayer,
    this.currentTurn,
    this.turnResult,
    this.score,
  );

  factory ApplicationState.initial() => ApplicationState(
        false,
        AtoupicView.Home,
        null,
        null,
        null,
        ScoreDisplay(0, 0),
      );
}
