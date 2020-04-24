import 'package:atoupic/domain/entity/game_context.dart';
import 'package:equatable/equatable.dart';

abstract class DeclarationsState extends Equatable {
  const DeclarationsState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class InitialDeclarationsState extends DeclarationsState {}

class AnalyzingDeclarations extends DeclarationsState {}

class FinishedAnalyzingDeclarations extends DeclarationsState {
  final GameContext gameContext;

  FinishedAnalyzingDeclarations(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}
