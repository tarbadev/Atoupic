import 'package:atoupic/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/ui/component/color_choices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TakeOrPassDialog extends StatelessWidget {
  final AtoupicCard.Card card;
  final bool displayRound2;
  final ColorChoices colorChoices;
  final Function onTakeTap;
  final Function onPassTap;

  const TakeOrPassDialog(
      {Key key, this.card, this.displayRound2, this.colorChoices, this.onTakeTap, this.onPassTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tileSize = screenSize.width / 9;
    final cardWidth = tileSize * 1.5;
    final cardHeight = tileSize * 1.5 * 1.39444;
    var container;
    if (displayRound2) {
      container = Container(
        child: Column(
          children: [
            Image.asset(
              'assets/images/cards/${card.color.folder}/${card.head.fileName}',
              fit: BoxFit.scaleDown,
              width: cardWidth,
              height: cardHeight,
            ),
            colorChoices,
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
                  Navigator.of(context).pop();
                  onTakeTap();
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
                  Navigator.of(context).pop();
                  onPassTap();
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
