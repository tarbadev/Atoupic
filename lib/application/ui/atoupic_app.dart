import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

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

class _MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  AtoupicGame game;
  CardService _cardService;
  PlayerService _playerService;
  Player _realPlayer;
  Color backgroundColor;

  @override
  void initState() {
    super.initState();

    var container = kiwi.Container();
    _cardService = container.resolve<CardService>();
    _playerService = container.resolve<PlayerService>();

    _realPlayer = _playerService.buildRealPlayer();

    game = container.resolve<AtoupicGame>();
    backgroundColor = Colors.white;
  }

  _displayGame() {
    game.visible = true;
    setState(() {
      backgroundColor = Colors.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        game.widget,
        Container(
          height: (MediaQuery.of(context).size.height),
          width: (MediaQuery.of(context).size.width),
          color: backgroundColor,
          child: Center(
            child: RaisedButton(
              key: Key('Home__SoloButton'),
              onPressed: _displayGame,
              color: Theme.of(context).backgroundColor,
              child: Text(
                'Solo',
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
