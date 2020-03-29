import 'package:atoupic/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _HomeViewModel _homeViewModel = _HomeViewModel.create();

    return Container(
      height: (MediaQuery.of(context).size.height),
      width: (MediaQuery.of(context).size.width),
      color: Colors.white,
      child: Center(
        child: RaisedButton(
          key: Key('Home__SoloButton'),
          onPressed: _homeViewModel.onStartSoloTap,
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

class _HomeViewModel {
  final Function onStartSoloTap;

  _HomeViewModel(this.onStartSoloTap);

  factory _HomeViewModel.create() {
    var gameBloc = kiwi.Container().resolve<GameBloc>();
    return _HomeViewModel(() => gameBloc.add(StartSoloGame()));
  }
}
