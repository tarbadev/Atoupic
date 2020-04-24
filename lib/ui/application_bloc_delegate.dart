import 'dart:async';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/error_reporter.dart';
import 'package:bloc/bloc.dart';

class ApplicationBlocDelegate extends BlocDelegate {
  final GameBloc _gameBloc;
  final TakeOrPassBloc _takeOrPassDialogBloc;
  final DeclarationsBloc _declarationsBloc;
  final ErrorReporter _errorReporter;

  ApplicationBlocDelegate(
    this._gameBloc,
    this._takeOrPassDialogBloc,
    this._errorReporter,
    this._declarationsBloc,
  );

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (transition.nextState is SoloGameInitialized) {
      _gameBloc.add(NewTurn(turnAlreadyCreated: true));
    } else if (transition.nextState is TurnCreated) {
      _makePlayerTakeOrPass(transition.nextState.turn.firstPlayer, transition.nextState.turn);
    } else if (transition.nextState is CardRoundCreated) {
      if (transition.nextState.gameContext.lastTurn.cardRounds.length == 1) {
        _declarationsBloc.add(AnalyseDeclarations(transition.nextState.gameContext));
      } else {
        _makePlayerPlayCard(transition.nextState.gameContext);
      }
    } else if (transition.nextState is FinishedAnalyzingDeclarations) {
      _makePlayerPlayCard(transition.nextState.gameContext);
    } else if (transition.nextState is CardPlayed) {
      _makePlayerPlayCard(transition.nextState.gameContext);
    } else if (transition.nextState is PlayerPassed) {
      _makePlayerTakeOrPass(
        transition.nextState.gameContext.nextPlayer(),
        transition.nextState.gameContext.lastTurn,
      );
    } else if (transition.nextState is PlayerTook) {
      _gameBloc.add(NewCardRound());
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    _errorReporter.report(error, stacktrace);
  }

  void _makePlayerTakeOrPass(Player player, Turn turn) {
    _takeOrPassDialogBloc.add(
      player.isRealPlayer ? RealPlayerTurn(player, turn) : ComputerPlayerTurn(player, turn),
    );
  }

  void _makePlayerPlayCard(GameContext gameContext) {
    var nextPlayer = gameContext.nextCardPlayer();

    if (nextPlayer == null) {
      Timer(Duration(seconds: 1), () {
        _gameBloc.add(EndCardRound());
      });
    } else {
      var event;
      if (nextPlayer.cards.length > 1) {
        var possibleCardsToPlay = gameContext.getPossibleCardsToPlay(nextPlayer);
        if (nextPlayer.isRealPlayer) {
          event = RealPlayerCanChooseCard(possibleCardsToPlay);
        } else {
          event = PlayCardForAi(nextPlayer, possibleCardsToPlay);
        }
      } else {
        event = PlayCard(nextPlayer.cards.first, nextPlayer);
      }
      _gameBloc.add(event);
    }
  }
}
