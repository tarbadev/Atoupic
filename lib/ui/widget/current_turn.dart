import 'package:atoupic/bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class CurrentTurn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentTurnBloc, int>(
      bloc: kiwi.Container().resolve<CurrentTurnBloc>(),
      builder: (BuildContext context, int currentTurn) {
        return Text(
          'Turn $currentTurn',
          key: Key('InGame__TurnCounter'),
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        );
      },
    );
  }
}
