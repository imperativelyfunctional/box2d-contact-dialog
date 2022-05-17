import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameDialog extends TextBoxComponent {
  final Color backgroundColor;
  final Color borderColor;

  GameDialog(
      String text, this.borderColor, this.backgroundColor, double dismissDelay)
      : super(
            text: text,
            priority: 2,
            textRenderer: TextPaint(
                style: const TextStyle(color: Colors.blue, fontSize: 10)),
            boxConfig: TextBoxConfig(
              margins: const EdgeInsets.all(10),
              timePerChar: 0.05,
              dismissDelay: dismissDelay,
              growingBox: true,
            ));

  @override
  void update(double dt) {
    super.update(dt);
    if (finished) {
      removeFromParent();
    }
  }

  @override
  void drawBackground(Canvas c) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = backgroundColor);
    c.drawRect(
        rect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
  }
}
