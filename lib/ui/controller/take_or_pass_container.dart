import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/widget/take_or_pass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TakeOrPassDialogContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TakeOrPassDialogBloc, TakeOrPassState>(
        builder: (BuildContext context, TakeOrPassState takeOrPassState) {
      if (takeOrPassState is ShowTakeOrPassDialog) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => showGeneralDialog(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                TakeOrPassDialog(
              card: takeOrPassState.card,
              displayRound2: takeOrPassState.isRound2,
              player: takeOrPassState.player,
            ),
            context: context,
            barrierDismissible: false,
            barrierColor: null,
            transitionDuration: const Duration(milliseconds: 150),
          ),
        );
      }
      return Container(color: Colors.transparent);
    });
  }
}
