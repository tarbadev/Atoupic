import 'package:equatable/equatable.dart';

abstract class CurrentTurnEvent extends Equatable {
  const CurrentTurnEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class UpdateCurrentTurn extends CurrentTurnEvent {
  final int turnNumber;

  UpdateCurrentTurn(this.turnNumber);

  @override
  List<Object> get props => [turnNumber];
}