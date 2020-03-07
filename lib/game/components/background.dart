import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';

class Background extends PositionComponent with Resizable {
  Rect rect;
  Paint paint;

  Background(int color) {
    paint = Paint();
    setColor(color);
  }

  void setColor(int color) {
    paint.color = Color(color);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }

  @override
  void resize(Size size) {
    rect = Rect.fromLTWH(
      x,
      y,
      width,
      height,
    );
    super.resize(size);
  }

  @override
  void update(double t) {}
}
