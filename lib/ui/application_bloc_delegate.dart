import 'dart:async';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/main.dart';
import 'package:bloc/bloc.dart';

class ApplicationBlocDelegate extends BlocDelegate {
  GameBloc _gameBloc;
  TakeOrPassDialogBloc _takeOrPassDialogBloc;

  ApplicationBlocDelegate(this._gameBloc, this._takeOrPassDialogBloc);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (transition.nextState is SoloGameInitialized) {
      _gameBloc.add(NewTurn(turnAlreadyCreated: true));
    } else if (transition.nextState is TurnCreated) {
      _makePlayerTakeOrPass(transition.nextState.turn.firstPlayer, transition.nextState.turn);
    } else if (transition.nextState is CardRoundCreated) {
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

  void _makePlayerTakeOrPass(Player player, Turn turn) {
    _takeOrPassDialogBloc.add(
      player.isRealPlayer ? RealPlayerTurn(player, turn) : ComputerPlayerTurn(player, turn),
    );
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    reportError(error, stacktrace);
  }

  void _makePlayerPlayCard(GameContext gameContext) {
    var nextPlayer = gameContext.nextCardPlayer();

    if (nextPlayer == null) {
      Timer(Duration(seconds: 1), () {
        _gameBloc.add(EndCardRound());
      });
    } else {
      var event;
      var possibleCardsToPlay = gameContext.getPossibleCardsToPlay(nextPlayer);
      if (nextPlayer.isRealPlayer) {
        event = RealPlayerCanChooseCard(possibleCardsToPlay);
      } else {
        event = PlayCardForAi(nextPlayer, possibleCardsToPlay);
      }
      _gameBloc.add(event);
    }
  }
}
