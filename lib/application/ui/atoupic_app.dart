import 'package:atoupic/application/ui/atoupic_game.dart';
import 'package:flutter/material.dart';

class AtoupicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atoupic',
      debugShowCheckedModeBanner: false,
      home: _MainPage(),
    );
  }
}

class _MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AtoupicGame().widget,
        Container(
          height: (MediaQuery.of(context).size.height),
          width: (MediaQuery.of(context).size.width),
          child: Center(
            child: Text('Atoupic'),
          ),
        ),
      ],
    );
  }
}
