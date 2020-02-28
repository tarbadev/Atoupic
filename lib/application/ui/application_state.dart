class ApplicationState {
  final bool showTakeOrPassDialog;

  ApplicationState(
    this.showTakeOrPassDialog,
  );

  factory ApplicationState.initial() => ApplicationState(false);
}
