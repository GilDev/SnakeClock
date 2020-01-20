// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';

const blinkInterval = 10; // In seconds

enum _Element {
  background,
  indications,
  leaf,
  tongue,
  eyes,
  body,
  spring,
  summer,
  fall,
  winter,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.indications: Colors.grey,
  _Element.leaf: Colors.lightGreen,
  _Element.tongue: Colors.red.shade700,
  _Element.eyes: Colors.black,
  _Element.body: null,
  _Element.spring: Colors.green.shade400,
  _Element.summer: Colors.amber.shade200,
  _Element.fall: Colors.orange,
  _Element.winter: Colors.blue.shade300,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.indications: Colors.grey,
  _Element.leaf: Colors.lightGreen,
  _Element.tongue: Colors.red.shade700,
  _Element.eyes: Colors.black,
  _Element.body: null,
  _Element.spring: Colors.green.shade400,
  _Element.summer: Colors.amber.shade200,
  _Element.fall: Colors.orange,
  _Element.winter: Colors.blue.shade300,
};

enum _Season {
  spring,
  summer,
  fall,
  winter,
}

final seasons = {
  _Season.spring: DateTime(0, 3, 1),
  _Season.summer: DateTime(0, 6, 1),
  _Season.fall: DateTime(0, 9, 1),
  _Season.winter: DateTime(0, 12, 1),
};

Future<ui.Image> load(String asset) async {
  ByteData data = await rootBundle.load(asset);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}

ui.Image appleYellow, appleRed, appleGreen;

class SnakeClock extends StatefulWidget {
  const SnakeClock(this.model);

  final ClockModel model;

  @override
  _SnakeClockState createState() => _SnakeClockState();
}

class _SnakeClockState extends State<SnakeClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  void loadApples() async {
    appleYellow = await load('assets/apple_yellow.png');
    appleRed = await load('assets/apple_red.png');
    appleGreen = await load('assets/apple_green.png');
  }

  @override
  void initState() {
    super.initState();
    loadApples();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(SnakeClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    // Set snake’s body color depending on the current season
    if (_dateTime.month >= seasons[_Season.winter].month ||
        _dateTime.month < seasons[_Season.spring].month) {
      colors[_Element.body] = colors[_Element.winter];
    } else if (_dateTime.month >= seasons[_Season.fall].month) {
      colors[_Element.body] = colors[_Element.fall];
    } else if (_dateTime.month >= seasons[_Season.summer].month) {
      colors[_Element.body] = colors[_Element.summer];
    } else {
      colors[_Element.body] = colors[_Element.spring];
    }

    return ClipRect(
      child: CustomPaint(
        painter: SnakePainter(_dateTime, colors),
        foregroundPainter:
            IndicationsPainter(_dateTime, colors, widget.model.is24HourFormat),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  DateTime time;
  final colors;

  double headX;
  double headY;

  SnakePainter(this.time, this.colors);

  void drawTongue(var canvas, double snakeThickness, double direction) {
    var paint = Paint()..color = colors[_Element.tongue];
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
    canvas.drawPaint(Paint()..color = colors[_Element.background]);

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
      ..color = colors[_Element.body];

    // Draw apples
    if (time.hour < 12) {
      // If it’s the morning
      if (time.hour < 9 || time.hour == 9 && time.minute < 29) {
        // Breakfast at 9h30
        drawApple(
          canvas,
          appleYellow,
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
          appleRed,
          snakeThickness,
          snakeStartPosX + snakeWidth * 30 / 60,
          snakeStartPosY + snakeIntervalY * 1,
        );
      }
      if (time.hour < 19 || time.hour == 19 && time.minute < 29) {
        // Dinner at 19h30
        drawApple(
          canvas,
          appleGreen,
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
      paint.color = colors[_Element.eyes];
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
      paint.color = colors[_Element.eyes];
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

class IndicationsPainter extends CustomPainter {
  DateTime time;
  final colors;
  final bool mode24Hour;

  IndicationsPainter(this.time, this.colors, this.mode24Hour);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..strokeWidth = .5
      ..color = colors[_Element.indications];

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
