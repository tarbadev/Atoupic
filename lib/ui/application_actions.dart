import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
import 'package:equatable/equatable.dart';

class SetTurnResultAction extends Equatable {
  final TurnResult turnResult;

  SetTurnResultAction(this.turnResult);

  @override
  List<Object> get props => [turnResult];

  @override
  String toString() {
    return 'SetTurnResultAction{turnResult: $turnResult}';
  }
}

class SetCurrentTurnAction extends Equatable {
  final Turn turn;

  SetCurrentTurnAction(this.turn);

  @override
  List<Object> get props => [turn];
}