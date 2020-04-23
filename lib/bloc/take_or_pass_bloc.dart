import 'dart:async';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:bloc/bloc.dart';

import './bloc.dart';

class TakeOrPassBloc extends Bloc<TakeOrPassEvent, TakeOrPassState> {
  final GameBloc _gameBloc;
  final GameService _gameService;
  final CardService _cardService;
  final AiService _aiService;

  TakeOrPassBloc(this._gameBloc, this._gameService, this._cardService, this._aiService);

  @override
  TakeOrPassState get initialState => HideTakeOrPass();

  @override
  Stream<TakeOrPassState> mapEventToState(
    TakeOrPassEvent event,
  ) async* {
    if (event is Take) {
      yield* _takeAndMapToState(event.player, event.color);
    } else if (event is Pass) {
      yield* _mapPassEventToState(event);
    } else if (event is RealPlayerTurn) {
      await Future.delayed(Duration(milliseconds: 500));
      yield event.turn.round == 1
          ? ShowTakeOrPassRound1(event.player)
          : ShowTakeOrPassRound2(event.player);
    } else if (event is ComputerPlayerTurn) {
      yield* _mapComputerPlayerTurnEventToState(event);
    }
  }

  Stream<TakeOrPassState> _takeAndMapToState(Player player, CardColor color) async* {
    var gameContext = _gameService.read().setDecision(player, Decision.Take);

    _gameBloc.add(DisplayPlayerTookCaption(player.position));
    _gameBloc.add(DisplayTrumpColor(color, player.position));

    await Future.delayed(Duration(milliseconds: 1000));

    var takerCards = _cardService.distributeCards(2).toList()..add(gameContext.lastTurn.card);

    gameContext.players.forEach((gamePlayer) {
      var newCards;
      if (gamePlayer.position == player.position) {
        newCards = takerCards;
      } else {
        newCards = _cardService.distributeCards(3);
      }

      gamePlayer.cards.addAll(newCards);
      _gameBloc.add(AddPlayerCards(newCards, gamePlayer.position));
    });

    gameContext.lastTurn.trumpColor = color;

    var realPlayer = gameContext.players.firstWhere((player) => player.isRealPlayer);
    realPlayer.sortCards(trumpColor: color);

    _gameService.save(gameContext);

    _gameBloc.add(ReplaceRealPlayersCards(realPlayer.cards));
    _gameBloc.add(ResetPlayersCaption());

    yield PlayerTook();
  }

  Stream<TakeOrPassState> _mapPassEventToState(Pass event) async* {
    yield* _passAndMapToState(event.player);
  }

  Stream<TakeOrPassState> _passAndMapToState(Player player) async* {
    yield HideTakeOrPass();
    var gameContext = _gameService.read().setDecision(player, Decision.Pass);

    _gameBloc.add(DisplayPlayerPassedCaption(player.position));

    if (gameContext.nextPlayer() == null && gameContext.lastTurn.round == 1) {
      await Future.delayed(Duration(milliseconds: 1000));
      gameContext = gameContext.nextRound();
      _gameBloc.add(ResetPlayersCaption());
    }

    _gameService.save(gameContext);

    if (gameContext.nextPlayer() == null && gameContext.lastTurn.round == 2) {
      await Future.delayed(Duration(milliseconds: 1000));
      yield NoOneTook();

      _gameBloc.add(NewTurn());
    } else {
      yield PlayerPassed(gameContext);
    }
  }

  Stream<TakeOrPassState> _mapComputerPlayerTurnEventToState(ComputerPlayerTurn event) async* {
    await Future.delayed(Duration(milliseconds: 1000));
    var result = _aiService.takeOrPass(event.player.cards, event.turn);
    if (result == null) {
      yield* _passAndMapToState(event.player);
    } else {
      yield* _takeAndMapToState(event.player, result);
    }
  }
}
