import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class PlayerName extends TextBoxComponent {
  PlayerName(String name) : super(name, config: TextConfig(fontSize: 18)) {
    anchor = Anchor.bottomRight;
  }

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()
      ..color = const Color(0xFFFFFFFF));
    c.drawRect(
      rect,
      new Paint()
        ..color = BasicPalette.black.color
        ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0,);
  }
}