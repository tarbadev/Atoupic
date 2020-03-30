import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/entity/score_display.dart';

class ApplicationState {
  final AtoupicView currentView;
  final Turn currentTurn;
  final ScoreDisplay score;

  ApplicationState(
    this.currentView,
    this.currentTurn,
    this.score,
  );

  factory ApplicationState.initial() => ApplicationState(
        AtoupicView.Home,
        null,
        ScoreDisplay(0, 0),
      );
}
