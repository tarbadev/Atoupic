import 'package:equatable/equatable.dart';

class ScoreDisplay extends Equatable {
  final int us;
  final int them;

  ScoreDisplay(this.us, this.them);

  @override
  List<Object> get props => [this.us, this.them];
}