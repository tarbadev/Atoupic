import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class HomeAppState extends AppState{}

class InGameAppState extends AppState {}
