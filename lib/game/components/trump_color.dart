import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/text_config.dart';

class TrumpColor extends TextBoxComponent {
  final CardColor color;

  TrumpColor(this.color)
      : super(
          '${color.symbol}  ',
          config: TextConfig(fontSize: 18, color: Color(0xFF000000), textAlign: TextAlign.left),
        ) {
    anchor = Anchor.center;
  }

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
    var borderPaint = Paint()
          ..color = Color(0xFF000000)
          ..style = PaintingStyle.stroke;
    c.drawRect(rect, borderPaint);
    c.drawRect(rect.deflate(1), borderPaint);
  }
}
