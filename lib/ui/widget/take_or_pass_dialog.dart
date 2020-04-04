import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/widget/color_choices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TakeOrPassDialog extends StatelessWidget {
  final AtoupicCard.Card card;
  final bool displayRound2;
  final Player player;

  const TakeOrPassDialog({Key key, this.card, this.displayRound2, this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var colorChoicesWidget;
    final screenSize = MediaQuery.of(context).size;
    final tileSize = screenSize.width / 9;
    final cardWidth = tileSize * 1.5;
    final cardHeight = tileSize * 1.5 * 1.39444;
    var container;
    if (displayRound2) {
      final List<CardColor> colorChoices = AtoupicCard.CardColor.values.toList()
        ..removeWhere((cardColor) => card.color == cardColor);
      colorChoicesWidget = ColorChoices.fromCardColorList(colorChoices);

      container = Container(
        child: Column(
          children: [
            Image.asset(
              'assets/images/cards/${card.color.folder}/${card.head.fileName}',
              fit: BoxFit.scaleDown,
              width: cardWidth,
              height: cardHeight,
            ),
            colorChoicesWidget,
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

    return Container(
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
                  var color = displayRound2 ? colorChoicesWidget.selectedColor : card.color;
                  kiwi.Container().resolve<TakeOrPassDialogBloc>().add(Take(player, color));
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
                  kiwi.Container().resolve<TakeOrPassDialogBloc>().add(Pass(player));
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
    );
  }
}
