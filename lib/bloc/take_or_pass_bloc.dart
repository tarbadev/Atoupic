import 'dart:async';

import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:bloc/bloc.dart';

import './bloc.dart';

class TakeOrPassBloc extends Bloc<TakeOrPassEvent, TakeOrPassState> {
  final GameBloc _gameBloc;
  final GameService _gameService;
  final CardService _cardService;

  TakeOrPassBloc(this._gameBloc, this._gameService, this._cardService) {}

  @override
  TakeOrPassState get initialState => HideTakeOrPassDialog();

  @override
  Stream<TakeOrPassState> mapEventToState(
    TakeOrPassEvent event,
  ) async* {
    if (event is Take) {
      yield* _mapTakeEventToState(event);
    } else if (event is Pass) {
      yield* _mapPassEventToState(event);
    } else if (event is RealPlayerTurn) {
      yield ShowTakeOrPassDialog(event.player, event.turn.card, event.turn.round == 2);
    }
  }

  Stream<TakeOrPassState> _mapTakeEventToState(Take event) async* {
    var gameContext = _gameService.read().setDecision(event.player, Decision.Take);
    var takerCards = _cardService.distributeCards(2).toList()..add(gameContext.lastTurn.card);

    gameContext.players.forEach((player) {
      var newCards;
      if (player.position == event.player.position) {
        newCards = takerCards;
      } else {
        newCards = _cardService.distributeCards(3);
      }

      player.cards.addAll(newCards);
      _gameBloc.add(AddPlayerCards(newCards, player.position));
    });

    gameContext.lastTurn.trumpColor = event.color;

    var realPlayer = gameContext.players.firstWhere((player) => player.isRealPlayer);
    realPlayer.sortCards(trumpColor: event.color);

    _gameService.save(gameContext);

    _gameBloc.add(DisplayTrumpColor(event.color, event.player.position));
    _gameBloc.add(ResetPlayersPassedCaption());
    _gameBloc.add(ReplaceRealPlayersCards(realPlayer.cards));

    yield PlayerTook(
        gameContext.players.firstWhere((player) => player.position == event.player.position));
  }

  Stream<TakeOrPassState> _mapPassEventToState(Pass event) async* {
    yield HideTakeOrPassDialog();
    var gameContext = _gameService.read().setDecision(event.player, Decision.Pass);

    _gameBloc.add(DisplayPlayerPassedCaption(event.player.position));

    if (gameContext.nextPlayer() == null && gameContext.lastTurn.round == 1) {
      gameContext = gameContext.nextRound();
      _gameBloc.add(ResetPlayersPassedCaption());
    }

    _gameService.save(gameContext);

    if (gameContext.nextPlayer() == null && gameContext.lastTurn.round == 2) {
      yield NoOneTook();

      _gameBloc.add(NewTurn());
    } else {
      yield PlayerPassed(gameContext);
    }
  }
}
