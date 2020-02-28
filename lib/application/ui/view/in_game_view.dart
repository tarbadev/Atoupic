import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
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
}

class _InGameViewModel {
  final bool showDialog;
  final AtoupicCard.Card takeOrPassCard;

  _InGameViewModel(this.showDialog, this.takeOrPassCard);

  factory _InGameViewModel.create(Store<ApplicationState> store) =>
      _InGameViewModel(
        store.state.showTakeOrPassDialog,
        store.state.takeOrPassCard,
      );
}
