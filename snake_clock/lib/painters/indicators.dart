import 'package:flutter/material.dart';

import 'package:snake_clock/constants.dart';

class IndicationsPainter extends CustomPainter {
  DateTime time;
  final colors;
  final bool mode24Hour;

  IndicationsPainter(this.time, this.colors, this.mode24Hour);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..strokeWidth = .5
      ..color = colors[Entity.indications];

    double snakeStartPosY = size.height / 9;
    double snakeIntervalY = (size.height - 2 * snakeStartPosY) / 11;
    double snakeStartPosX = size.width / 10;
    double snakeEndPosX = size.width / 10 * 9;
    double snakeWidth = snakeEndPosX - snakeStartPosX;
    double leftIndicatorPosX = snakeStartPosX + snakeWidth / 4 * 1;
    double centerIndicatorPosX = snakeStartPosX + snakeWidth / 4 * 2;
    double rightIndicatorPostX = snakeStartPosX + snakeWidth / 4 * 3;
    String leftIndicatorText = time.hour.isEven ? '15' : '45';
    String centerIndicatorText = '30';
    String rightIndicatorText = time.hour.isEven ? '45' : '15';

    double lineStartY = 20;
    double lineEndY = size.height - lineStartY;
    int dashWidth = 5;
    int dashSpace = 12;
    final int space = dashWidth + dashSpace;
    double startY = lineStartY;

    // Vertical dashed lines
    for (; startY < lineEndY; startY += space) {
      // 15 min line
      canvas.drawLine(
        Offset(leftIndicatorPosX, startY),
        Offset(leftIndicatorPosX, startY + dashWidth),
        paint,
      );

      // 30 min line
      canvas.drawLine(
        Offset(centerIndicatorPosX, startY),
        Offset(centerIndicatorPosX, startY + dashWidth),
        paint,
      );

      // 45 min line
      canvas.drawLine(
        Offset(rightIndicatorPostX, startY),
        Offset(rightIndicatorPostX, startY + dashWidth),
        paint,
      );
    }

    final textStyle = TextStyle(
      color: Colors.grey,
      fontSize: size.width / 36,
    );

    // Top indicators
    var textPainter = TextPainter(
      text: TextSpan(text: leftIndicatorText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(leftIndicatorPosX - textPainter.width / 2, 0),
    );

    textPainter.text = TextSpan(text: centerIndicatorText, style: textStyle);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(centerIndicatorPosX - textPainter.width / 2, 0),
    );

    textPainter.text = TextSpan(text: rightIndicatorText, style: textStyle);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(rightIndicatorPostX - textPainter.width / 2, 0),
    );

    // Bottom indicators
    textPainter.text = TextSpan(text: leftIndicatorText, style: textStyle);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(leftIndicatorPosX - textPainter.width / 2,
          size.height - textPainter.height),
    );

    textPainter.text = TextSpan(text: centerIndicatorText, style: textStyle);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(centerIndicatorPosX - textPainter.width / 2,
          size.height - textPainter.height),
    );

    textPainter.text = TextSpan(text: rightIndicatorText, style: textStyle);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(rightIndicatorPostX - textPainter.width / 2,
          size.height - textPainter.height),
    );

    // Side indicators
    textPainter.textAlign = TextAlign.center;
    for (int hour = 0; hour < 12; hour++) {
      String hourText;
      if (mode24Hour) {
        if (time.hour >= 12) {
          hourText = (hour + 12).toString();
        } else {
          hourText = hour.toString();
        }
      } else {
        hourText = (hour == 0 ? 12 : hour).toString();
      }

      textPainter.text = TextSpan(
        text: hourText,
        style: textStyle,
      );
      textPainter.layout(minWidth: 40, maxWidth: size.width);
      double textY =
          snakeStartPosY + hour * snakeIntervalY - textPainter.height / 2;
      textPainter.paint(
        canvas,
        Offset(
          0,
          textY,
        ),
      );

      textPainter.paint(
        canvas,
        Offset(
          size.width - textPainter.width,
          textY,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(IndicationsPainter oldDelegate) => false;
}
