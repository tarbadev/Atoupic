import 'dart:async';

import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:bloc/bloc.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:redux/redux.dart';

import './bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final AtoupicGame _atoupicGame;
  final AppBloc _appBloc;
  final GameService _gameService;

  GameBloc(this._atoupicGame, this._appBloc, this._gameService);

  @override
  GameState get initialState => NotStarted();

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if (event is StartSoloGame) {
      final gameContext = _gameService.startSoloGame();

      _atoupicGame.setDomainPlayers(gameContext.players);
      _atoupicGame.visible = true;

      yield SoloGameInitialized();

      _appBloc.add(GameInitialized());
    } else if (event is NewTurn) {
      yield CreatingTurn();

      _atoupicGame.resetPlayersPassed();
      _atoupicGame.resetTrumpColor();
      _atoupicGame.resetPlayersCards();

      GameContext gameContext = _gameService.startTurn(event.turnAlreadyCreated);

      gameContext.players.forEach((player) => _atoupicGame.addPlayerCards(player.cards, player.position));

      yield TurnCreated(gameContext.lastTurn);
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
    } else if (event is RealPlayerCanChooseCard) {
      _atoupicGame.realPlayerCanChooseCard(true, possiblePlayableCards: event.cards);
    } else if (event is SetPlayedCard) {
      _atoupicGame.realPlayerCanChooseCard(false);
      _atoupicGame.setLastCardPlayed(event.card, event.position, event.onCardPlayed);
    } else if (event is ResetLastPlayedCards) {
      _atoupicGame.resetLastPlayedCards();
    } else if (event is NewCardRound) {
      yield CreatingCardRound();

      final gameContext  = _gameService.save(_gameService.read().newCardRound());

      yield CardRoundCreated(gameContext);

      var store = kiwi.Container().resolve<Store<ApplicationState>>();
      store.dispatch(ChooseCardDecisionAction(gameContext));
    }
  }
}
