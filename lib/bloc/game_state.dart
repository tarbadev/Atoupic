import 'package:equatable/equatable.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

class NotStarted extends GameState {}
class Initialized extends GameState {}
