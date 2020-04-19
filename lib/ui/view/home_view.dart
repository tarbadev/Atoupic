import 'package:atoupic/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: (MediaQuery.of(context).size.height),
        width: (MediaQuery.of(context).size.width),
        color: Color(0xFF006a64),
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  'Atoupic',
                  style: TextStyle(
                    fontSize: 46.0,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontFamily: "EmilysCandy",
                    letterSpacing: 3,
                  ),
                ),
              ),
              OutlineButton(
                key: Key('Home__SoloButton'),
                onPressed: () => context.bloc<GameBloc>().add(StartSoloGame()),
                textColor: Colors.white,
                borderSide: BorderSide(color: Colors.white, width: 2),
                highlightedBorderColor: Color(0xFF079992),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Text(
                  'Solo Game',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      );
}
