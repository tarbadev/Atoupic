import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/text_config.dart';

class PassedCaption extends TextBoxComponent {
  bool visible = false;

  PassedCaption() : super('Passed   ', config: TextConfig(fontSize: 18)) {
    anchor = Anchor.bottomRight;
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
  }
}