import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
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
      converter: (Store<ApplicationState> store) =>
          _InGameViewModel.create(store),
      builder: (BuildContext context, _InGameViewModel viewModel) {
        if (viewModel.showDialog) {
          var screenSize = MediaQuery.of(context).size;
          var tileSize = screenSize.width / 9;
          var cardWidth = tileSize * 1.5;
          var cardHeight = tileSize * 1.5 * 1.39444;
          var card = viewModel.takeOrPassCard;
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
                                key: Key('TakeOrPassDialog__TakeButton'),
                                color: Color(0xff27ae60),
                                onPressed: () {
                                  viewModel.onTakeTap();
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
                                key: Key('TakeOrPassDialog__PassButton'),
                                color: Color(0xffc0392b),
                                onPressed: () {
                                  viewModel.onPassTap();
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
}

class _InGameViewModel {
  final bool showDialog;
  final int turnCounter;
  final AtoupicCard.Card takeOrPassCard;
  final Function onPassTap;
  final Function onTakeTap;

  _InGameViewModel(
      this.showDialog, this.turnCounter, this.takeOrPassCard, this.onPassTap, this.onTakeTap);

  factory _InGameViewModel.create(Store<ApplicationState> store) =>
      _InGameViewModel(
        store.state.showTakeOrPassDialog,
        store.state.turn,
        store.state.takeOrPassCard,
        () {
          store.dispatch(ShowTakeOrPassDialogAction(false));
          store.dispatch(PassDecisionAction(store.state.realPlayer));
        },
        () {
          store.dispatch(ShowTakeOrPassDialogAction(false));
          store.dispatch(TakeDecisionAction(store.state.realPlayer));
        },
      );
}
