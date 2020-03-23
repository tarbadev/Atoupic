import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ApplicationState, _HomeViewModel>(
        converter: (Store<ApplicationState> store) => _HomeViewModel.create(store),
        builder: (BuildContext context, _HomeViewModel viewModel) {
          return Container(
            height: (MediaQuery.of(context).size.height),
            width: (MediaQuery.of(context).size.width),
            color: Colors.white,
            child: Center(
              child: RaisedButton(
                key: Key('Home__SoloButton'),
                onPressed: viewModel.onStartSoloTap,
                color: Theme.of(context).backgroundColor,
                child: Text(
                  'Solo',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ),
          );
        });
  }
}

class _HomeViewModel {
  final Function onStartSoloTap;

  _HomeViewModel(this.onStartSoloTap);

  factory _HomeViewModel.create(Store<ApplicationState> store) =>
      _HomeViewModel(() => store.dispatch(StartSoloGameAction()));
}
