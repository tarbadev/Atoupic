import 'dart:async';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:bloc/bloc.dart';

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

      _atoupicGame.resetPlayersDialog();
      _atoupicGame.resetTrumpColor();
      _atoupicGame.resetPlayersCards();

      GameContext gameContext = _gameService.startTurn(event.turnAlreadyCreated);

      gameContext.players
          .forEach((player) => _atoupicGame.addPlayerCards(player.cards, player.position));

      yield TurnCreated(gameContext.lastTurn);
    } else if (event is DisplayPlayerCaption) {
      _atoupicGame.setPlayerDialogText(event.position, event.caption);
    } else if (event is DisplayTrumpColor) {
      _atoupicGame.setTrumpColor(event.color, event.takerPosition);
    } else if (event is ResetPlayersCaption) {
      _atoupicGame.resetPlayersDialog();
    } else if (event is AddPlayerCards) {
      _atoupicGame.addPlayerCards(event.cards, event.position);
    } else if (event is ReplaceRealPlayersCards) {
      _atoupicGame.replaceRealPlayersCards(event.cards);
    } else if (event is RealPlayerCanChooseCard) {
      _atoupicGame.realPlayerCanChooseCard(true, possiblePlayableCards: event.cards);
    } else if (event is NewCardRound) {
      yield CreatingCardRound();

      final gameContext = _gameService.save(_gameService.read().newCardRound());
      await Future.delayed(Duration(seconds: 1));

      yield CardRoundCreated(gameContext);
    } else if (event is PlayCardForAi) {
      yield* _mapPlayCardForAiEventToState(event);
    } else if (event is PlayCard) {
      yield* _mapPlayCardEventToState(event);
    } else if (event is EndCardRound) {
      yield* _mapEndCardRoundEventToState(event);
    } else if (event is EndGame) {
      yield* _mapEndGameEventToState(event);
    }
  }

  Stream<GameState> _mapPlayCardForAiEventToState(PlayCardForAi event) async* {
    var gameContext = _gameService.read();
    var card = _aiService.chooseCard(
      event.possibleCardsToPlay,
      gameContext.lastTurn,
      event.player.position,
    );

    yield* _setCardAndAnimate(gameContext, card, event.player);
  }

  Stream<GameState> _setCardAndAnimate(GameContext gameContext, Card card, Player player) async* {
    var newGameContext = gameContext.setCardDecision(card, player);
    var beloteResult = newGameContext.isPlayedCardBelote(card, player);

    if (beloteResult != BeloteResult.None) {
      _atoupicGame.setPlayerDialogText(
          player.position, beloteResult == BeloteResult.Belote ? 'Belote!' : 'Rebelote!');
    }

    _gameService.save(newGameContext);

    Completer completer = new Completer();
    yield CardAnimationStarted();
    _atoupicGame.setLastCardPlayed(card, player.position, () => completer.complete());
    await completer.future;
    yield CardAnimationEnded();
    await Future.delayed(Duration(milliseconds: 500));

    yield CardPlayed(newGameContext);
  }

  Stream<GameState> _mapPlayCardEventToState(PlayCard event) async* {
    var gameContext = _gameService.read();
    _atoupicGame.realPlayerCanChooseCard(false);
    yield* _setCardAndAnimate(gameContext, event.card, event.player);
  }

  Stream<GameState> _mapEndCardRoundEventToState(EndCardRound event) async* {
    _atoupicGame.resetPlayersDialog();

    var gameContext = _gameService.read();

    var winner =
        gameContext.lastTurn.lastCardRound.getCardRoundWinner(gameContext.lastTurn.trumpColor).key;
    Completer completer = new Completer();
    _atoupicGame.removePlayedCardsToWinnerPile(winner, () => completer.complete());
    await completer.future;

    if (gameContext.lastTurn.cardRounds.length >= 8) {
      gameContext.lastTurn.calculatePoints(gameContext.players);
      _gameService.save(gameContext);

      final gameScore = getGameScore(gameContext);
      final usScore = gameScore[0];
      final themScore = gameScore[1];

      final pointsNeededToWin = 501;
      var isGameOver = usScore >= pointsNeededToWin || themScore >= pointsNeededToWin;

      yield TurnEnded(
        gameContext.lastTurn.turnResult,
        isGameOver: isGameOver,
      );
    } else {
      gameContext = gameContext.newCardRound();
      _gameService.save(gameContext);

      yield CardRoundCreated(gameContext);
    }
  }

  List<int> getGameScore(gameContext) {
    var usScore = 0;
    var themScore = 0;

    gameContext.turns.where((turn) => turn.turnResult != null).forEach((turn) {
      usScore += turn.turnResult.verticalScore;
      themScore += turn.turnResult.horizontalScore;
    });

    return [usScore, themScore];
  }

  Stream<GameState> _mapEndGameEventToState(EndGame event) async* {
    final gameContext = _gameService.read();
    final gameScore = getGameScore(gameContext);

    final usScore = gameScore[0];
    final themScore = gameScore[1];

    yield GameEnded(usScore, themScore);
  }
}
