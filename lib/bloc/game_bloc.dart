import 'dart:async';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/ai_service.dart';
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
  final AiService _aiService;

  GameBloc(this._atoupicGame, this._appBloc, this._gameService, this._aiService);

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

      gameContext.players
          .forEach((player) => _atoupicGame.addPlayerCards(player.cards, player.position));

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

      final gameContext = _gameService.save(_gameService.read().newCardRound());

      yield CardRoundCreated(gameContext);
    } else if (event is PlayCardForAi) {
      yield* _mapPlayCardForAiEventToState(event);
    } else if (event is PlayCard) {
      yield* _mapPlayCardEventToState(event);
    } else if (event is EndCardRound) {
      yield* _mapEndCardRoundEventToState(event);
    }
  }

  Stream<GameState> _mapPlayCardForAiEventToState(PlayCardForAi event) async* {
    var gameContext = _gameService.read();
    var card = _aiService.chooseCard(
      event.possibleCardsToPlay,
      gameContext.lastTurn,
      event.player.position.isVertical,
    );

    yield* _setCardAndAnimate(gameContext, card, event.player);
  }

  Stream<GameState> _setCardAndAnimate(GameContext gameContext, Card card, Player player) async* {
    var newGameContext = gameContext.setCardDecision(card, player);
    _gameService.save(newGameContext);

    Completer completer = new Completer();
    yield CardAnimationStarted();
    _atoupicGame.setLastCardPlayed(card, player.position, () => completer.complete());
    await completer.future;
    yield CardAnimationEnded();

    yield CardPlayed(newGameContext);
  }

  Stream<GameState> _mapPlayCardEventToState(PlayCard event) async* {
    var gameContext = _gameService.read();
    _atoupicGame.realPlayerCanChooseCard(false);
    yield* _setCardAndAnimate(gameContext, event.card, event.player);
  }

  Stream<GameState> _mapEndCardRoundEventToState(EndCardRound event) async* {
    _atoupicGame.resetLastPlayedCards();

    var gameContext = _gameService.read();
    if (gameContext.lastTurn.cardRounds.length >= 8) {
      gameContext.lastTurn.calculatePoints(gameContext.players);
      _gameService.save(gameContext);
      yield TurnEnded();

      var store = kiwi.Container().resolve<Store<ApplicationState>>();
      store.dispatch(SetCurrentTurnAction(gameContext.lastTurn));
      store.dispatch(SetTurnResultAction(gameContext.lastTurn.turnResult));
    } else {
      gameContext = gameContext.newCardRound();
      _gameService.save(gameContext);

      yield CardRoundCreated(gameContext);
    }
  }
}
