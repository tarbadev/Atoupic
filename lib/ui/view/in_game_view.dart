import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:atoupic/ui/widget/current_turn.dart';
import 'package:atoupic/ui/widget/end_game_dialog.dart';
import 'package:atoupic/ui/widget/score.dart';
import 'package:atoupic/ui/widget/take_or_pass.dart';
import 'package:atoupic/ui/widget/turn_result_dialog_container.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class InGameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AtoupicGame atoupicGame = kiwi.Container().resolve();
    final Rect centerSpace = atoupicGame.getCenterRect();

    return Scaffold(
      key: Key('InGame__Container'),
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.all(5),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: CurrentTurn(),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Score(),
            ),
            TurnResultDialogContainer(),
            EndGameDialog(),
            Positioned(
              left: centerSpace.left,
              top: centerSpace.top,
              width: centerSpace.right - centerSpace.left,
              height: centerSpace.bottom - centerSpace.top,
              child: TakeOrPass(),
            ),
          ],
        ),
      ),
    );
  }
}
