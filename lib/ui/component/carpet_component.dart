import 'dart:async';
import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/card_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/tapable.dart';

class CarpetComponent extends Component with HasGameRef, Tapable, ComposedComponent {
  void cleanUpCarpetToWinner(Position winner, Function onAnimationEnd, Offset centerOffset) async {
    final List<CardComponent> cards = components.toList().cast();

    List<Completer> completerList = List();
    cards.forEach((card) {
      var completer = Completer();
      card.animateToOffset(centerOffset, () => completer.complete());
      completerList.add(completer);
    });
    for(var completer in completerList) {
      await completer.future;
    }

    completerList.clear();
    cards.forEach((card) {
      var completer = Completer();
      card.animateToWinnerPile(winner, () {
        card.setToDestroy();
        completer.complete();
      });
      completerList.add(completer);
    });
    for(var completer in completerList) {
      await completer.future;
    }

    Timer(Duration(milliseconds: 500), onAnimationEnd);
  }

  @override
  Rect toRect() {
    return Rect.zero;
  }
}