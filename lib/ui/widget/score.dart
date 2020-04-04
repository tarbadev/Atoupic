import 'package:atoupic/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Score extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var usScore = 0;
    var themScore = 0;

    return BlocBuilder<GameBloc, GameState>(builder: (BuildContext context, GameState state) {
      if (state is TurnEnded) {
        usScore += state.turnResult.verticalScore;
        themScore += state.turnResult.horizontalScore;
      } else if (state is TurnCreated && state.turn.number == 1) {
        usScore = 0;
        themScore = 0;
      }

      return ScoreDisplay(usScore: usScore, themScore: themScore);
    });
  }
}

class ScoreDisplay extends StatelessWidget {
  final int usScore;
  final int themScore;

  const ScoreDisplay({Key key, this.usScore, this.themScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreTextStyle = TextStyle(fontSize: 14.0, color: Colors.white);
    final titleTextStyle = TextStyle(fontSize: 16.0, color: Colors.white);
    final double dividerWidth = 10;
    final double horizontalPadding = 10;

    return Container(
      key: Key('Score'),
      color: Colors.black87,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Score',
            style: titleTextStyle,
          ),
          Divider(height: 5),
          Row(
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Text(
                        'Us',
                        style: scoreTextStyle,
                      ),
                    ),
                    Text(
                      usScore.toString(),
                      key: Key('Score__Us'),
                      style: scoreTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: dividerWidth,
                child: VerticalDivider(
                  color: Colors.grey,
                  width: dividerWidth,
                  thickness: 1,
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Text(
                        themScore.toString(),
                        key: Key('Score__Them'),
                        style: scoreTextStyle,
                      ),
                    ),
                    Text(
                      'Them',
                      style: scoreTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
