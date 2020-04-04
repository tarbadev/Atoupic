import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class GameInitialized extends AppEvent {}
class GameFinished extends AppEvent {}