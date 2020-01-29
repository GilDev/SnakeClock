import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:snake_clock/constants.dart';

class SnakePainter extends CustomPainter {
  DateTime time;
  final colors;
  final apples;

  double headX;
  double headY;

  SnakePainter(this.time, this.colors, this.apples);

  void drawTongue(var canvas, double snakeThickness, double direction) {
    var paint = Paint()..color = colors[Entity.tongue];
    double length = time.second.isEven ? snakeThickness : snakeThickness * 1.3;

    Path tongue = Path();
    tongue.moveTo(headX, headY - snakeThickness / 6);
    tongue.relativeLineTo(length * direction, 0);
    tongue.relativeLineTo(-5 * direction, snakeThickness / 6);
    tongue.relativeLineTo(5 * direction, snakeThickness / 6);
    tongue.relativeLineTo(-length * direction, 0);
    tongue.close();

    canvas.drawPath(tongue, paint);
  }

  // Draw an apple at the center of the given coordinates
  void drawApple(
      var canvas, ui.Image image, double snakeThickness, double x, double y) {
    double imageWidth = snakeThickness * 1.2;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, 500, 500),
      Rect.fromLTWH(
        x - imageWidth / 2,
        y - imageWidth / 2,
        imageWidth,
        imageWidth,
      ),
      Paint(),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawPaint(Paint()..color = colors[Entity.background]);

    int nbHoursToDraw = (time.hour >= 12) ? time.hour - 12 : time.hour;
    double snakeStartPosY = size.height / 9;
    double snakeIntervalY = (size.height - 2 * snakeStartPosY) / 11;
    double snakeThickness = snakeIntervalY / 1.25;
    double snakeStartPosX = size.width / 10;
    double snakeEndPosX = size.width / 10 * 9;
    double snakeWidth = snakeEndPosX - snakeStartPosX;
    headY = snakeStartPosY + nbHoursToDraw * snakeIntervalY;
    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = snakeThickness
      ..color = colors[Entity.body];

    // Draw apples
    if (time.hour < 12) {
      // If it’s the morning
      if (time.hour < 9 || time.hour == 9 && time.minute < 29) {
        // Breakfast at 9h30
        drawApple(
          canvas,
          apples[Apple.yellow],
          snakeThickness,
          snakeStartPosX + snakeWidth * 30 / 60,
          snakeStartPosY + snakeIntervalY * 9,
        );
      }
    } else {
      // If it’s the afternoon
      if (time.hour < 13 || time.hour == 13 && time.minute < 29) {
        // Lunch at 13h30
        drawApple(
          canvas,
          apples[Apple.red],
          snakeThickness,
          snakeStartPosX + snakeWidth * 30 / 60,
          snakeStartPosY + snakeIntervalY * 1,
        );
      }
      if (time.hour < 19 || time.hour == 19 && time.minute < 29) {
        // Dinner at 19h30
        drawApple(
          canvas,
          apples[Apple.green],
          snakeThickness,
          snakeStartPosX + snakeWidth * 30 / 60,
          snakeStartPosY + snakeIntervalY * 7,
        );
      }
    }

    // Draw column at top left if it’s the afternoon to show it’s the same day
    if (time.hour >= 12) {
      canvas.drawLine(
        Offset(snakeStartPosX, 0),
        Offset(snakeStartPosX, snakeStartPosY),
        paint,
      );
    }

    // Draw all complete lines
    for (var hours = 0; hours < nbHoursToDraw; hours++) {
      // Draw lines
      canvas.drawLine(
        Offset(snakeStartPosX, snakeStartPosY + hours * snakeIntervalY),
        Offset(snakeEndPosX, snakeStartPosY + hours * snakeIntervalY),
        paint,
      );

      // Draw turn arounds
      if (hours.isOdd) {
        // Draw left turn
        canvas.drawLine(
          Offset(snakeStartPosX, snakeStartPosY + hours * snakeIntervalY),
          Offset(snakeStartPosX,
              snakeStartPosY + hours * snakeIntervalY + snakeIntervalY),
          paint,
        );
      } else {
        // Draw right turn
        canvas.drawLine(
          Offset(snakeEndPosX, snakeStartPosY + hours * snakeIntervalY),
          Offset(snakeEndPosX,
              snakeStartPosY + hours * snakeIntervalY + snakeIntervalY),
          paint,
        );
      }
    }

    // Draw current hour line
    if (nbHoursToDraw.isEven) {
      // Draw line starting from the left side
      headX = snakeStartPosX +
          (snakeWidth * time.minute / 60 +
              (snakeWidth / 60 * time.second / 60));

      drawTongue(canvas, snakeThickness, 1);

      // Draw body
      canvas.drawLine(
        Offset(snakeStartPosX, headY),
        Offset(headX, headY),
        paint,
      );

      // Draw eyes
      paint.color = colors[Entity.eyes];
      paint.strokeWidth = 1;

      if ((time.second % blinkInterval) == 0) {
        // Blink eyes
        // Draw left (top) eye
        canvas.drawLine(
          Offset(headX + 1, headY - snakeThickness / 3),
          Offset(headX + 1, headY - 1),
          paint,
        );
        // Draw right (bottom) eye
        canvas.drawLine(
          Offset(headX + 1, headY + snakeThickness / 3),
          Offset(headX + 1, headY + 1),
          paint,
        );
      } else {
        // Open eyes
        // Draw left (top) eye
        canvas.drawOval(
          Rect.fromLTRB(
            headX - snakeThickness / 4,
            headY - snakeThickness / 3,
            headX + snakeThickness / 3,
            headY - 1,
          ),
          paint,
        );
        // Draw right (bottom) eye
        canvas.drawOval(
          Rect.fromLTRB(
            headX - snakeThickness / 4,
            headY + snakeThickness / 3,
            headX + snakeThickness / 3,
            headY + 1,
          ),
          paint,
        );
      }
    } else {
      // Draw line starting from the right side
      headX = snakeEndPosX -
          (snakeWidth * time.minute / 60 +
              (snakeWidth / 60 * time.second / 60));

      drawTongue(canvas, snakeThickness, -1);

      // Draw body
      canvas.drawLine(
        Offset(snakeEndPosX, headY),
        Offset(headX, headY),
        paint,
      );

      // Draw eyes
      paint.color = colors[Entity.eyes];
      paint.strokeWidth = 1;

      if ((time.second % blinkInterval) == 0) {
        // Blink eyes
        // Draw right (top) eye
        canvas.drawLine(
          Offset(headX - 1, headY - snakeThickness / 3),
          Offset(headX - 1, headY - 1),
          paint,
        );
        // Draw left (bottom) eye
        canvas.drawLine(
          Offset(headX - 1, headY + snakeThickness / 3),
          Offset(headX - 1, headY + 1),
          paint,
        );
      } else {
        // Open eyes
        // Draw right (top) eye
        canvas.drawOval(
          // Rect.fromLTRB(headX + 4, headY - 7, headX - 6, headY - 1),
          Rect.fromLTRB(
            headX + snakeThickness / 4,
            headY - snakeThickness / 3,
            headX - snakeThickness / 3,
            headY - 1,
          ),
          paint,
        );
        // Draw left (bottom) eye
        canvas.drawOval(
          // Rect.fromLTRB(headX + 4, headY + 7, headX - 6, headY + 1),
          Rect.fromLTRB(
            headX + snakeThickness / 4,
            headY + snakeThickness / 3,
            headX - snakeThickness / 3,
            headY + 1,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) {
    if (oldDelegate.time.second != time.second) {
      return true;
    }

    return false;
  }
}
