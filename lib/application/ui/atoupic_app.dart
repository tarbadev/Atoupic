import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/view/home_view.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:redux/redux.dart';

enum AtoupicView { Home, InGame }

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

class _MainPage extends StatelessWidget {
  final AtoupicGame _game = kiwi.Container().resolve<AtoupicGame>();
  final HomeView _homeView = HomeView();
  final InGameView _inGameView = InGameView();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ApplicationState, _AtoupicAppModel>(
        converter: (Store<ApplicationState> store) =>
            _AtoupicAppModel.create(store),
        builder: (BuildContext context, _AtoupicAppModel viewModel) {
          var currentView;
          switch (viewModel.currentView) {
            case AtoupicView.Home:
              currentView = _homeView;
              break;
            case AtoupicView.InGame:
              currentView = _inGameView;
              break;
          }
          return Stack(
            children: <Widget>[
              _game.widget,
              GestureDetector(
                onTap: _game.onTap,
                onTapDown: _game.onTapDown,
                onTapUp: _game.onTapUp,
                onTapCancel: _game.onTapCancel,
                child: currentView,
              ),
            ],
          );
        });
  }
}

class _AtoupicAppModel {
  final AtoupicView currentView;

  _AtoupicAppModel(this.currentView);

  factory _AtoupicAppModel.create(Store<ApplicationState> store) =>
      _AtoupicAppModel(
        store.state.currentView,
      );
}
