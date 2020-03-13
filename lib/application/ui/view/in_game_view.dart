import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class InGameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<ApplicationState, _InGameViewModel>(
      converter: (Store<ApplicationState> store) => _InGameViewModel.create(store),
      builder: (BuildContext context, _InGameViewModel viewModel) {
        if (viewModel.showDialog) {
          displayTakeOrPassDialog(context, viewModel);
        }
        if (viewModel.turnResultDisplay != null) {
          displayTurnResultDialog(context, viewModel.turnResultDisplay, viewModel.onTurnResultNext);
        }
        return Container(
          child: Scaffold(
            key: Key('InGame__Container'),
            backgroundColor: Colors.transparent,
            body: Text(
              'Turn ${viewModel.turnCounter}',
              key: Key('InGame__TurnCounter'),
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void displayTakeOrPassDialog(BuildContext context, _InGameViewModel viewModel) {
    var screenSize = MediaQuery.of(context).size;
    var tileSize = screenSize.width / 9;
    var cardWidth = tileSize * 1.5;
    var cardHeight = tileSize * 1.5 * 1.39444;
    var card = viewModel.takeOrPassCard;
    var container;
    if (viewModel.showRound2Dialog) {
      container = Container(
        child: Column(
          children: [
            Image.asset(
              'assets/images/cards/${card.color.folder}/${card.head.fileName}',
              fit: BoxFit.scaleDown,
              width: cardWidth,
              height: cardHeight,
            ),
            viewModel.colorChoices,
          ],
        ),
      );
    } else {
      container = Container(
        height: cardHeight,
        width: cardWidth,
        child: Image.asset(
          'assets/images/cards/${card.color.folder}/${card.head.fileName}',
          fit: BoxFit.scaleDown,
        ),
      );
    }

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
                    container,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        RaisedButton(
                          key: Key('TakeOrPassDialog__TakeButton'),
                          color: Color(0xff27ae60),
                          onPressed: () {
                            viewModel.onTakeTap();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Take!',
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20),
                        RaisedButton(
                          key: Key('TakeOrPassDialog__PassButton'),
                          color: Color(0xffc0392b),
                          onPressed: () {
                            viewModel.onPassTap();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Pass!',
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
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

  void displayTurnResultDialog(
      BuildContext context, TurnResultDisplay turnResultDisplay, Function onNextPressed) async {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => showDialog(
        context: context,
        child: SimpleDialog(
          key: Key('TurnResultDialog'),
          title: Center(
            child: Text(
              turnResultDisplay.result,
              key: Key('TurnResultDialog__Result'),
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'Taker: ${turnResultDisplay.taker}',
                    key: Key('TurnResultDialog__Taker'),
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        turnResultDisplay.takerScore.toString(),
                        key: Key('TurnResultDialog__TakerScore'),
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Container(
                          height: 20,
                          child: VerticalDivider(
                            color: Colors.grey,
                            thickness: 2,
                          )),
                      Text(
                        turnResultDisplay.opponentScore.toString(),
                        key: Key('TurnResultDialog__OpponentScore'),
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                  SimpleDialogOption(
                    key: Key('TurnResultDialog__NextButton'),
                    onPressed: () {
                      Navigator.pop(context);
                      onNextPressed();
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InGameViewModel {
  final bool showDialog;
  final bool showRound2Dialog;
  final ColorChoices colorChoices;
  final int turnCounter;
  final AtoupicCard.Card takeOrPassCard;
  final Function onPassTap;
  final Function onTakeTap;
  final TurnResultDisplay turnResultDisplay;
  final Function onTurnResultNext;

  _InGameViewModel(
    this.showDialog,
    this.showRound2Dialog,
    this.colorChoices,
    this.turnCounter,
    this.takeOrPassCard,
    this.onPassTap,
    this.onTakeTap,
    this.turnResultDisplay,
    this.onTurnResultNext,
  );

  factory _InGameViewModel.create(Store<ApplicationState> store) {
    final lastTurn = store.state.gameContext.lastTurn;
    final List<CardColor> colorChoices =
        lastTurn.card == null ? [] : AtoupicCard.CardColor.values.toList()
          ..removeWhere((cardColor) => lastTurn.card.color == cardColor);
    var colorChoicesWidget = ColorChoices(colorChoices);

    _onTake() {
      var cardColor = lastTurn.card.color;
      if (lastTurn.round == 2) {
        cardColor = colorChoicesWidget.selectedColor;
      }
      store.dispatch(ShowTakeOrPassDialogAction(false));
      store.dispatch(TakeDecisionAction(store.state.realPlayer, cardColor));
    }

    return _InGameViewModel(
      store.state.showTakeOrPassDialog,
      store.state.showTakeOrPassDialog && lastTurn.round == 2,
      colorChoicesWidget,
      lastTurn.number,
      lastTurn.card,
      () {
        store.dispatch(ShowTakeOrPassDialogAction(false));
        store.dispatch(PassDecisionAction(store.state.realPlayer));
      },
      () {
        store.dispatch(ShowTakeOrPassDialogAction(false));
        _onTake();
      },
      store.state.turnResult == null
          ? null
          : TurnResultDisplay.fromTurnResult(store.state.turnResult),
      () {
        store.dispatch(SetTurnResultAction(null));
        store.dispatch(StartTurnAction(store.state.gameContext));
      },
    );
  }
}

class TurnResultDisplay {
  final String taker;
  final int takerScore;
  final int opponentScore;
  final String result;

  TurnResultDisplay(this.taker, this.takerScore, this.opponentScore, this.result);

  static TurnResultDisplay fromTurnResult(TurnResult turnResult) {
    Position takerPosition = turnResult.taker.position;
    var takerScore =
        takerPosition.isVertical ? turnResult.verticalScore : turnResult.horizontalScore;
    var opponentScore =
        takerPosition.isVertical ? turnResult.horizontalScore : turnResult.verticalScore;

    return TurnResultDisplay(
      takerPosition.toString(),
      takerScore,
      opponentScore,
      turnResult.result == Result.Success ? 'Contract fulfilled' : 'Contract failed',
    );
  }
}

class ColorChoices extends StatefulWidget {
  final List<AtoupicCard.CardColor> colorChoices;
  _ColorChoicesState _choices;

  AtoupicCard.CardColor get selectedColor => _choices.selectedColor;

  ColorChoices(this.colorChoices) {
    _choices = new _ColorChoicesState(colorChoices);
  }

  @override
  State<StatefulWidget> createState() {
    return _choices;
  }
}

class _ColorChoicesState extends State<ColorChoices> {
  final List<AtoupicCard.CardColor> colorChoices;
  AtoupicCard.CardColor selectedColor;

  _ColorChoicesState(this.colorChoices);

  onColorChoiceTap(AtoupicCard.CardColor cardColor) {
    setState(() {
      selectedColor = cardColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key('TakeOrPassDialog__ColorChoices'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: colorChoices
          .map((colorChoice) => Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: RaisedButton(
                  color: colorChoice == selectedColor ? Colors.white : Colors.grey,
                  onPressed: () => onColorChoiceTap(colorChoice),
                  child: Text(colorChoice.symbol,
                      style: TextStyle(
                        fontSize: 30.0,
                        color: colorChoice == AtoupicCard.CardColor.Diamond ||
                                colorChoice == AtoupicCard.CardColor.Heart
                            ? Colors.red
                            : Colors.black,
                      )),
                ),
              ))
          .toList(),
    );
  }
}
