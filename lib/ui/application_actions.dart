import 'package:atoupic/domain/entity/turn.dart';
import 'package:equatable/equatable.dart';

class SetCurrentTurnAction extends Equatable {
  final Turn turn;

  SetCurrentTurnAction(this.turn);

  @override
  List<Object> get props => [turn];
}