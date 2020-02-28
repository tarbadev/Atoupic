import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/view/home_view.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:redux/redux.dart';

class AtoupicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = kiwi.Container();
    final _store = container<Store<ApplicationState>>();

    return StoreProvider<ApplicationState>(
      store: _store,
      child: MaterialApp(
        title: 'Atoupic',
        debugShowCheckedModeBanner: false,
        home: _MainPage(),
      ),
    );
  }
}

class _MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  AtoupicGame _game;
  HomeView _homeView;
  InGameView _inGameView;
  Widget _currentView;

  @override
  void initState() {
    super.initState();

    _homeView = HomeView(_startSoloGame);
    _inGameView = InGameView();

    _currentView = _homeView;

    _game = kiwi.Container().resolve<AtoupicGame>();
  }

  _startSoloGame() {
    setState(() {
      _currentView = _inGameView;
    });
    _inGameView.startSoloGame();
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
