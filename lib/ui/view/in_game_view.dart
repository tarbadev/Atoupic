import 'package:atoupic/ui/component/score.dart';
import 'package:atoupic/ui/widget/current_turn.dart';
import 'package:atoupic/ui/widget/end_game_dialog_container.dart';
import 'package:atoupic/ui/widget/take_or_pass_container.dart';
import 'package:atoupic/ui/widget/turn_result_dialog_container.dart';
import 'package:flutter/material.dart';

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
                    child: Score(),
                  ),
                ],
              ),
            ),
            TakeOrPassDialogContainer(),
            TurnResultDialogContainer(),
            EndGameDialogContainer(),
          ],
        ),
      ),
    );
  }
}
