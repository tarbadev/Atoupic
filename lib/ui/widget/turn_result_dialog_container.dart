import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/entity/turn_result_display.dart';
import 'package:atoupic/ui/widget/turn_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TurnResultDialogContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (BuildContext context, GameState state) {
      print(state);
      if (state is TurnEnded) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => showDialog(
            barrierDismissible: false,
            context: context,
            child: TurnResultDialog(
              turnResultDisplay: TurnResultDisplay.fromTurnResult(state.turnResult),
              onNextPressed: () => kiwi.Container()
                  .resolve<GameBloc>()
                  .add(state.isGameOver ? EndGame() : NewTurn()),
            ),
          ),
        );
      }
      return Container(color: Colors.transparent);
    });
  }
}
