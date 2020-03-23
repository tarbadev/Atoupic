import 'dart:async';

import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:bloc/bloc.dart';

import './bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final AtoupicGame _atoupicGame;

  GameBloc(this._atoupicGame);

  @override
  GameState get initialState => NotStarted();

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if (event is Start) {
      _atoupicGame.setDomainPlayers(event.players);
      _atoupicGame.visible = true;
      yield Initialized();
    } else if (event is NewTurn) {
      _atoupicGame.resetPlayersPassed();
      _atoupicGame.resetTrumpColor();
      _atoupicGame.resetPlayersCards();
      
      event.players.forEach((player) => _atoupicGame.addPlayerCards(player.cards, player.position));
    } else if (event is DisplayPlayerPassedCaption) {
      _atoupicGame.setPlayerPassed(event.position);
    } else if (event is DisplayTrumpColor) {
      _atoupicGame.setTrumpColor(event.color, event.takerPosition);
    } else if (event is ResetPlayersPassedCaption) {
      _atoupicGame.resetPlayersPassed();
    } else if (event is AddPlayerCards) {
      _atoupicGame.addPlayerCards(event.cards, event.position);
    } else if (event is ReplaceRealPlayersCards) {
      _atoupicGame.replaceRealPlayersCards(event.cards);
    }
  }
}
