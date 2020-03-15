import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
import 'package:flutter/material.dart';

class ColorChoices extends StatefulWidget {
  final _ColorChoicesState _choices;

  AtoupicCard.CardColor get selectedColor => _choices.selectedColor;

  ColorChoices(this._choices);

  ColorChoices.fromCardColorList(List<AtoupicCard.CardColor> colorChoices)
      : _choices = _ColorChoicesState(colorChoices);

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
