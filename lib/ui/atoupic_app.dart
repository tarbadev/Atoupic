import 'package:atoupic/bloc/app_state.dart';
import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:atoupic/ui/view/home_view.dart';
import 'package:atoupic/ui/view/in_game_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:redux/redux.dart';

enum AtoupicView { Home, InGame }

class AtoupicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = kiwi.Container();
    final _store = container<Store<ApplicationState>>();
    BlocSupervisor.delegate = container<ApplicationBlocDelegate>();

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _game.widget,
        GestureDetector(
          onTap: _game.onTap,
          onTapDown: _game.onTapDown,
          onTapUp: _game.onTapUp,
          onTapCancel: _game.onTapCancel,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => kiwi.Container().resolve<GameBloc>()),
              BlocProvider(create: (_) => kiwi.Container().resolve<AppBloc>()),
              BlocProvider(create: (_) => kiwi.Container().resolve<TakeOrPassDialogBloc>()),
            ],
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is InGameAppState) {
                  return InGameView();
                } else {
                  return HomeView();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
