mixin Destroyable {
  bool _shouldDestroy = false;

  void setToDestroy() => _shouldDestroy = true;

  bool destroy() => _shouldDestroy;
}