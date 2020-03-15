import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

enum Result { Success, Failure }

class TurnResult extends Equatable {
  final Player taker;
  final int horizontalCardPoints;
  final int verticalCardPoints;
  final int horizontalScore;
  final int verticalScore;
  final Result result;

  TurnResult(this.taker, this.horizontalCardPoints, this.verticalCardPoints,
      this.result, this.horizontalScore, this.verticalScore);

  @override
  List<Object> get props => [
    this.taker,
    this.horizontalCardPoints,
    this.verticalCardPoints,
    this.result,
    this.horizontalScore,
    this.verticalScore,
  ];

  @override
  String toString() {
    return 'TurnResult{taker: $taker, horizontalCardPoints: $horizontalCardPoints, verticalCardPoints: $verticalCardPoints, horizontalScore: $horizontalScore, verticalScore: $verticalScore, result: $result}';
  }
}