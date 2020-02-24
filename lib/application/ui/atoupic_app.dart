import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:atoupic/application/ui/view/home_view.dart';
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
  AtoupicGame _game;
  GameService _gameService;
  Widget _homeView;
  Widget _inGameView;
  Widget _currentView;

  @override
  void initState() {
    super.initState();

    _homeView = HomeView(_startSoloGame);
    _inGameView = InGameView();

    var container = kiwi.Container();
    _gameService = container.resolve<GameService>();

    _currentView = _homeView;

    _game = container.resolve<AtoupicGame>();
  }

  _startSoloGame() {
    _gameService.startSoloGame();
    setState(() {
      _currentView = _inGameView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _game.widget,
        _currentView,
      ],
    );
  }
}