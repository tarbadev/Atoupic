import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/entity/turn_result.dart';

class TurnResultDisplay {
  final String taker;
  final int takerScore;
  final int opponentScore;
  final String result;

  TurnResultDisplay(this.taker, this.takerScore, this.opponentScore, this.result);

  TurnResultDisplay.fromTurnResult(TurnResult turnResult)
      : taker = turnResult.taker.position.toString(),
        takerScore = turnResult.taker.position.isVertical
            ? turnResult.verticalScore
            : turnResult.horizontalScore,
        opponentScore = turnResult.taker.position.isVertical
            ? turnResult.horizontalScore
            : turnResult.verticalScore,
        result = turnResult.result == Result.Success ? 'Contract fulfilled' : 'Contract failed';
}