import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:redux/redux.dart';

class InGameView extends StatelessWidget {
  GameContext gameContext;

  GameService _gameService;
  CardService _cardService;
  AtoupicGame _atoupicGame;
  AtoupicCard.Card card;

  InGameView() {
    var container = kiwi.Container();
    _gameService = container.resolve<GameService>();
    _atoupicGame = container.resolve();
    _cardService = container.resolve();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ApplicationState, _InGameViewModel>(
      converter: (Store<ApplicationState> store) =>
          _InGameViewModel.create(store),
      builder: (BuildContext context, _InGameViewModel viewModel) {
        if (viewModel.showDialog) {
          var screenSize = MediaQuery.of(context).size;
          var tileSize = screenSize.width / 9;
          var cardWidth = tileSize * 1.5;
          var cardHeight = tileSize * 1.5 * 1.39444;
          SchedulerBinding.instance.addPostFrameCallback(
            (_) => showGeneralDialog(
                pageBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) =>
                    Container(
                      child: Column(
                        key: Key('TakeOrPassDialog'),
                        children: <Widget>[
                          Container(
                            height: cardHeight,
                            width: cardWidth,
                            child: Image.asset(
                              'assets/images/cards/${card.color.folder}/${card.head.fileName}',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              RaisedButton(
                                color: Color(0xff27ae60),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Take!',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 20),
                              RaisedButton(
                                color: Color(0xffc0392b),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Pass!',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                context: context,
                barrierDismissible: false,
                barrierColor: null,
                transitionDuration: const Duration(milliseconds: 150)),
          );
        }
        return Container(
          child: Scaffold(
            key: Key('InGame__Container'),
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }

  void startSoloGame() {
    gameContext = _gameService.startSoloGame();

    _setPlayersInGame();

    _atoupicGame.visible = true;

    takeOrPass();
  }

  void _setPlayersInGame() {
    _atoupicGame.setPlayers(gameContext.players
        .map((player) => PlayerComponent.fromPlayer(
              player,
              passed: gameContext.turns.last.playerDecisions[player] ==
                  Decision.Pass,
            ))
        .toList());
  }

  void takeOrPass() {
    card = _cardService.distributeCards(1).first;

    _proposeCardToPlayer(gameContext.nextPlayer());
  }

  void _proposeCardToPlayer(Player player) {
    if (player.isRealPlayer) {
      final Store<ApplicationState> store = kiwi.Container().resolve();
      store.dispatch(ShowTakeOrPassDialogAction(true));
    } else {
      onTakeOrPassDecision(gameContext.nextPlayer(), Decision.Pass);
    }
  }

  onTakeOrPassDecision(Player player, Decision decision) {
    var newGameContext = gameContext.setDecision(player, decision);
    gameContext = _gameService.save(newGameContext);

    _setPlayersInGame();

    _nextAction();
  }

  void _nextAction() {
    _proposeCardToPlayer(gameContext.nextPlayer());
  }
}

class _InGameViewModel {
  final bool showDialog;

  _InGameViewModel(this.showDialog);

  factory _InGameViewModel.create(Store<ApplicationState> store) =>
      _InGameViewModel(
        store.state.showTakeOrPassDialog,
      );
}
