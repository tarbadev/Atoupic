import 'package:atoupic/bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class EndGameDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (BuildContext context, GameState state) {
      if (state is GameEnded) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => showDialog(
            barrierDismissible: false,
            context: context,
            child: AlertDialog(
              key: Key('GameResultDialog'),
              title: Text(
                state.usScore > state.themScore ? 'Congratulations!' : 'You Lost!',
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
                        state.usScore.toString(),
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
                        state.themScore.toString(),
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
                    kiwi.Container().resolve<AppBloc>().add(GameFinished());
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
                    kiwi.Container().resolve<GameBloc>().add(StartSoloGame());
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
      return Container(color: Colors.transparent);
    });
  }
}
