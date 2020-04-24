import 'package:atoupic/domain/entity/game_context.dart';
import 'package:equatable/equatable.dart';

abstract class DeclarationsEvent extends Equatable {
  const DeclarationsEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class AnalyseDeclarations extends DeclarationsEvent {
  final GameContext gameContext;

  AnalyseDeclarations(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}
