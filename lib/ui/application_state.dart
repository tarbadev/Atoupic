import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/entity/score_display.dart';

class ApplicationState {
  final Turn currentTurn;
  final ScoreDisplay score;

  ApplicationState(
    this.currentTurn,
    this.score,
  );

  factory ApplicationState.initial() => ApplicationState(
        null,
        ScoreDisplay(0, 0),
      );
}
