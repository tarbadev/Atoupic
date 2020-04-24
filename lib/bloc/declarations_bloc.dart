import 'dart:async';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:bloc/bloc.dart';

import './bloc.dart';

class DeclarationsBloc extends Bloc<DeclarationsEvent, DeclarationsState> {
  final GameService _gameService;
  final GameBloc _gameBloc;

  DeclarationsBloc(this._gameBloc, this._gameService);

  @override
  DeclarationsState get initialState => InitialDeclarationsState();

  @override
  Stream<DeclarationsState> mapEventToState(
    DeclarationsEvent event,
  ) async* {
    switch (event.runtimeType) {
      case AnalyseDeclarations:
        yield* _mapAnalyseDeclaration(event);
        break;
    }
  }

  Stream<DeclarationsState> _mapAnalyseDeclaration(AnalyseDeclarations event) async* {
    yield AnalyzingDeclarations();

    final gameContext = _gameService.lookForDeclarations();

    await Future.forEach(gameContext.lastTurn.playerDeclarations.entries, (entry) async {
      await Future.forEach(entry.value, (declaration) async {
        final position = entry.key;
        _gameBloc.add(DisplayPlayerCaption(
          position,
          _getDeclarationCaption(declaration),
        ));

        await Future.delayed(Duration(seconds: 1));
      });
    });

    yield FinishedAnalyzingDeclarations(gameContext);
  }

  String _getDeclarationCaption(Declaration declaration) {
    switch (declaration.type) {
      case DeclarationType.Tierce:
        return 'Tierce!';
      case DeclarationType.Quarte:
        return 'Quarte!';
      case DeclarationType.Quinte:
        return 'Quinte!';
      case DeclarationType.Square:
        return 'Square of ${_getCardHeadCarreCaption(declaration.cards.first.head)}!';
      default:
        return '';
    }
  }

  String _getCardHeadCarreCaption(CardHead cardHead) {
    return '${cardHead.toString().substring(cardHead.runtimeType.toString().length + 1)}s';
  }
}
