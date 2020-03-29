import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class HomeAppState extends AppState{}

class InGameAppState extends AppState {}
