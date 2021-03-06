import 'dart:ui';

import 'package:atoupic/ui/component/destroyable.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/text_config.dart';

class PlayerDialog extends TextBoxComponent with Destroyable {
  PlayerDialog(String text) : super(text, config: TextConfig(fontSize: 16)) {
    anchor = Anchor.bottomRight;
  }

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
  }
}