import 'package:equatable/equatable.dart';

class ShowTakeOrPassDialogAction extends Equatable {
  final bool show;

  ShowTakeOrPassDialogAction(this.show);

  @override
  List<Object> get props => [show];
}