import 'package:atoupic/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/component/color_choices.dart';
import 'package:atoupic/ui/component/score.dart';
import 'package:atoupic/ui/component/take_or_pass_dialog.dart';
import 'package:atoupic/ui/component/turn_result_dialog.dart';
import 'package:atoupic/ui/entity/score_display.dart';
import 'package:atoupic/ui/entity/turn_result_display.dart';
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
        if (viewModel.showTakeOrPassDialog) {
          displayTakeOrPassDialog(context, viewModel);
        }
        if (viewModel.turnResultDisplay != null) {
          SchedulerBinding.instance.addPostFrameCallback(
            (_) => showDialog(
              barrierDismissible: false,
              context: context,
              child: TurnResultDialog(
                turnResultDisplay: viewModel.turnResultDisplay,
                onNextPressed: viewModel.onTurnResultNext,
              ),
            ),
          );
        }
        return Container(
          child: Scaffold(
            key: Key('InGame__Container'),
            backgroundColor: Colors.transparent,
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Text(
                      'Turn ${viewModel.turnCounter}',
                      key: Key('InGame__TurnCounter'),
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 6,
                    child: Divider(),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 2,
                    child: Score(usScore: viewModel.score.us, themScore: viewModel.score.them),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void displayTakeOrPassDialog(BuildContext context, _InGameViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => showGeneralDialog(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              TakeOrPassDialog(
                card: viewModel.takeOrPassCard,
                displayRound2: viewModel.showRound2Dialog,
                colorChoices: viewModel.colorChoices,
                onTakeTap: viewModel.onTakeTap,
                onPassTap: viewModel.onPassTap,
              ),
          context: context,
          barrierDismissible: false,
          barrierColor: null,
          transitionDuration: const Duration(milliseconds: 150)),
    );
  }
}

class _InGameViewModel {
  final bool showTakeOrPassDialog;
  final bool showRound2Dialog;
  final ColorChoices colorChoices;
  final int turnCounter;
  final AtoupicCard.Card takeOrPassCard;
  final Function onPassTap;
  final Function onTakeTap;
  final TurnResultDisplay turnResultDisplay;
  final Function onTurnResultNext;
  final ScoreDisplay score;

  _InGameViewModel(
    this.showTakeOrPassDialog,
    this.showRound2Dialog,
    this.colorChoices,
    this.turnCounter,
    this.takeOrPassCard,
    this.onPassTap,
    this.onTakeTap,
    this.turnResultDisplay,
    this.onTurnResultNext,
    this.score,
  );

  factory _InGameViewModel.create(Store<ApplicationState> store) {
    final currentTurn = store.state.currentTurn;
    final List<CardColor> colorChoices = (currentTurn == null || currentTurn.card == null)
        ? []
        : AtoupicCard.CardColor.values.toList()
      ..removeWhere((cardColor) => currentTurn.card.color == cardColor);
    var colorChoicesWidget = ColorChoices.fromCardColorList(colorChoices);

    _onTake() {
      var cardColor = currentTurn.card.color;
      if (currentTurn.round == 2) {
        cardColor = colorChoicesWidget.selectedColor;
      }
      store.dispatch(ShowTakeOrPassDialogAction(false));
      store.dispatch(TakeDecisionAction(store.state.realPlayer, cardColor));
    }

    return _InGameViewModel(
      store.state.showTakeOrPassDialog,
      currentTurn.round == 2,
      colorChoicesWidget,
      currentTurn.number,
      currentTurn.card,
      () {
        store.dispatch(ShowTakeOrPassDialogAction(false));
        store.dispatch(PassDecisionAction(store.state.realPlayer));
      },
      () {
        store.dispatch(ShowTakeOrPassDialogAction(false));
        _onTake();
      },
      currentTurn.turnResult == null
          ? null
          : TurnResultDisplay.fromTurnResult(currentTurn.turnResult),
      () {
        store.dispatch(SetTurnResultAction(null));
        store.dispatch(StartTurnAction());
      },
      store.state.score,
    );
  }
}
