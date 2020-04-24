import 'package:atoupic/domain/entity/card.dart';
import 'package:equatable/equatable.dart';

enum DeclarationType { Tierce, Quarte, Quinte, Square }

class Declaration extends Equatable {
  final DeclarationType type;
  final List<Card> cards;

  Declaration(this.type, this.cards);

  @override
  List<Object> get props => [type, cards];

  @override
  bool get stringify => true;
}
