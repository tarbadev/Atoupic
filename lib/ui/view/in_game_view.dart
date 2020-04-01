import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/component/score.dart';
import 'package:atoupic/ui/component/turn_result_dialog.dart';
import 'package:atoupic/ui/controller/take_or_pass_container.dart';
import 'package:atoupic/ui/entity/score_display.dart';
import 'package:atoupic/ui/entity/turn_result_display.dart';
import 'package:atoupic/ui/widget/current_turn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class InGameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: Key('InGame__Container'),
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: CurrentTurn(),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 6,
                    child: Divider(color: Colors.transparent),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 2,
                    child: StoreConnector<ApplicationState, _InGameViewModel>(
                      converter: (Store<ApplicationState> store) => _InGameViewModel.create(store),
                      builder: (BuildContext context, _InGameViewModel viewModel) =>
                          Score(usScore: viewModel.score.us, themScore: viewModel.score.them),
                    ),
                  ),
                ],
              ),
            ),
            TakeOrPassDialogContainer(),
            StoreConnector<ApplicationState, _InGameViewModel>(
              converter: (Store<ApplicationState> store) => _InGameViewModel.create(store),
              builder: (BuildContext context, _InGameViewModel viewModel) {
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
                if (viewModel.showEndGameDialog) {
                  SchedulerBinding.instance.addPostFrameCallback(
                    (_) => showDialog(
                      barrierDismissible: false,
                      context: context,
                      child: AlertDialog(
                        key: Key('GameResultDialog'),
                        title: Text(
                          viewModel.score.us > viewModel.score.them
                              ? 'Congratulations!'
                              : 'You Lost!',
                          key: Key('GameResultDialog__Result'),
                          style: TextStyle(fontSize: 22.0),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  viewModel.score.us.toString(),
                                  key: Key('GameResultDialog__UsScore'),
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                Container(
                                    height: 20,
                                    child: VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 2,
                                    )),
                                Text(
                                  viewModel.score.them.toString(),
                                  key: Key('GameResultDialog__ThemScore'),
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          RaisedButton(
                            key: Key('GameResultDialog__HomeButton'),
                            color: Theme.of(context).backgroundColor,
                            onPressed: () {
                              Navigator.pop(context);
                              viewModel.onHomeTap();
                            },
                            child: Text(
                              'Home',
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ),
                          RaisedButton(
                            key: Key('GameResultDialog__NewGameButton'),
                            color: Theme.of(context).backgroundColor,
                            onPressed: () {
                              Navigator.pop(context);
                              viewModel.onNewGameTap();
                            },
                            child: Text(
                              'New Game',
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InGameViewModel {
  final TurnResultDisplay turnResultDisplay;
  final Function onTurnResultNext;
  final ScoreDisplay score;
  final bool showEndGameDialog;
  final Function onHomeTap;
  final Function onNewGameTap;

  _InGameViewModel(
    this.turnResultDisplay,
    this.onTurnResultNext,
    this.score,
    this.showEndGameDialog,
    this.onHomeTap,
    this.onNewGameTap,
  );

  factory _InGameViewModel.create(Store<ApplicationState> store) {
    final currentTurn = store.state.currentTurn;
    final isGameOver = store.state.score.us >= 501 || store.state.score.them >= 501;

    _onEndTurnNext() {
      store.dispatch(SetTurnResultAction(null));
      if (!isGameOver) {
        store.dispatch(StartTurnAction());
      }
    }

    return _InGameViewModel(
      currentTurn?.turnResult == null
          ? null
          : TurnResultDisplay.fromTurnResult(currentTurn?.turnResult),
      _onEndTurnNext,
      store.state.score,
      currentTurn?.turnResult == null && isGameOver,
      () => store.dispatch(SetCurrentViewAction(AtoupicView.Home)),
      () => store.dispatch(StartSoloGameAction()),
    );
  }
}
