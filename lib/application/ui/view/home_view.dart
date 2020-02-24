import 'package:flutter/material.dart';

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
