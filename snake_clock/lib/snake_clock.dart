// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';

import 'package:snake_clock/constants.dart';
import 'package:snake_clock/painters/snake.dart';
import 'package:snake_clock/painters/indicators.dart';

Future<ui.Image> load(String asset) async {
  ByteData data = await rootBundle.load(asset);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}

class SnakeClock extends StatefulWidget {
  const SnakeClock(this.model);

  final ClockModel model;

  @override
  _SnakeClockState createState() => _SnakeClockState();
}

class _SnakeClockState extends State<SnakeClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var apples = {};

  void loadApples() async {
    apples[Apple.yellow] = await load('assets/apple_yellow.png');
    apples[Apple.red] = await load('assets/apple_red.png');
    apples[Apple.green] = await load('assets/apple_green.png');
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
        ? lightTheme
        : darkTheme;

    // Set snake’s body color depending on the current season
    if (_dateTime.month >= seasons[Season.winter].month ||
        _dateTime.month < seasons[Season.spring].month) {
      colors[Entity.body] = colors[Entity.winter];
    } else if (_dateTime.month >= seasons[Season.fall].month) {
      colors[Entity.body] = colors[Entity.fall];
    } else if (_dateTime.month >= seasons[Season.summer].month) {
      colors[Entity.body] = colors[Entity.summer];
    } else {
      colors[Entity.body] = colors[Entity.spring];
    }

    return ClipRect(
      child: CustomPaint(
        painter: SnakePainter(_dateTime, colors, apples),
        foregroundPainter:
            IndicationsPainter(_dateTime, colors, widget.model.is24HourFormat),
      ),
    );
  }
}
