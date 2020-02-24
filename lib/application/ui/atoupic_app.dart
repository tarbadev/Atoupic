import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
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
  GameService _gameService;
  PlayerService _playerService;
  Player _realPlayer;
  Color backgroundColor;
  Widget _homeView;
  Widget _gameView;
  Widget _currentView;

  @override
  void initState() {
    super.initState();

    _homeView = HomeView(_startSoloGame);

    var container = kiwi.Container();
    _gameService = container.resolve<GameService>();
    _playerService = container.resolve<PlayerService>();

    _realPlayer = _playerService.buildRealPlayer();
    _currentView = _homeView;

    game = container.resolve<AtoupicGame>();
    backgroundColor = Colors.white;
  }

  _startSoloGame() {
    _gameService.startSoloGame();
    _currentView = _gameView;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        game.widget,
        _currentView,
      ],
    );
  }
}

class HomeView extends StatelessWidget {
  final Function _onStartSoloGameTap;

  const HomeView(this._onStartSoloGameTap, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (MediaQuery.of(context).size.height),
      width: (MediaQuery.of(context).size.width),
      color: Colors.white,
      child: Center(
        child: RaisedButton(
          key: Key('Home__SoloButton'),
          onPressed: _onStartSoloGameTap,
          color: Theme.of(context).backgroundColor,
          child: Text(
            'Solo',
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ),
    );
  }
}
