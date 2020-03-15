import 'package:atoupic/ui/entity/turn_result_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TurnResultDialog extends StatelessWidget {
  final TurnResultDisplay turnResultDisplay;
  final Function onNextPressed;

  const TurnResultDialog({Key key, this.turnResultDisplay, this.onNextPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: Key('TurnResultDialog'),
      title: Text(
        turnResultDisplay.result,
        key: Key('TurnResultDialog__Result'),
        style: TextStyle(fontSize: 22.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
      actions: <Widget>[
        FlatButton(
          key: Key('TurnResultDialog__NextButton'),
          onPressed: () {
            Navigator.pop(context);
            onNextPressed();
          },
          child: Text('Next'),
        ),
      ],
    );
  }
}