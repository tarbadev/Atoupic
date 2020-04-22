import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/domain/entity/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TakeOrPass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _takeButton({@required Function onPressed, @required Widget child, Key key}) {
      var borderColor = Color(0xff81c784);
      return ButtonTheme(
        height: 0,
        child: OutlineButton(
          key: key,
          padding: EdgeInsets.all(5),
          textColor: Colors.white,
          borderSide: BorderSide(color: borderColor, width: 2),
          highlightedBorderColor: borderColor,
          onPressed: onPressed,
          child: child,
        ),
      );
    }

    Widget _passButton({@required Player player}) {
      var borderColor = Color(0xffc0392b);
      return ButtonTheme(
        height: 0,
        padding: EdgeInsets.all(5),
        child: OutlineButton(
          key: Key('TakeOrPassContainer__PassButton'),
          padding: EdgeInsets.all(5),
          textColor: Colors.white,
          borderSide: BorderSide(color: borderColor, width: 2),
          highlightedBorderColor: borderColor,
          onPressed: () => kiwi.Container().resolve<TakeOrPassBloc>().add(Pass(player)),
          child: Text(
            'Pass!',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      );
    }

    return BlocBuilder<GameBloc, GameState>(builder: (BuildContext context, GameState state) {
      var child;
      if (state is TurnCreated) {
        final AtoupicCard.Card card = state.turn.card;

        child = Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset(
                  'assets/images/cards/${card.color.folder}/${card.head.fileName}',
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: BlocBuilder<TakeOrPassBloc, TakeOrPassState>(
                    builder: (BuildContext context, TakeOrPassState takeOrPassState) {
                  var buttons = <Widget>[];
                  if (takeOrPassState is ShowTakeOrPassRound1) {
                    buttons = [
                      Flexible(
                        child: _takeButton(
                          key: Key('TakeOrPassContainer__TakeButton'),
                          onPressed: () => kiwi.Container()
                              .resolve<TakeOrPassBloc>()
                              .add(Take(takeOrPassState.player, card.color)),
                          child: Text(
                            'Take!',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Flexible(
                        child: _passButton(player: takeOrPassState.player),
                      ),
                    ];
                  } else if (takeOrPassState is ShowTakeOrPassRound2) {
                    final List<AtoupicCard.CardColor> colorChoices = AtoupicCard.CardColor.values
                        .toList()
                          ..removeWhere((cardColor) => card.color == cardColor);
                    buttons = colorChoices
                        .map(
                          (colorChoice) => Flexible(
                            child: _takeButton(
                              onPressed: () => kiwi.Container()
                                  .resolve<TakeOrPassBloc>()
                                  .add(Take(takeOrPassState.player, colorChoice)),
                              child: Text(colorChoice.symbol,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: colorChoice == AtoupicCard.CardColor.Diamond ||
                                            colorChoice == AtoupicCard.CardColor.Heart
                                        ? Colors.red
                                        : Colors.black,
                                  )),
                            ),
                          ),
                        )
                        .toList()
                          ..add(Flexible(
                            child: _passButton(player: takeOrPassState.player),
                          ));
                  }
                  return Scaffold(
                    body: Column(
                      key: Key('TakeOrPassContainer__Buttons'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: buttons,
                    ),
                    backgroundColor: Colors.transparent,
                  );
                }),
              ),
            ),
          ],
        );
      }

      return Container(
        key: Key('TakeOrPassContainer'),
        margin: EdgeInsets.all(30),
        child: child,
      );
    });
  }
}
