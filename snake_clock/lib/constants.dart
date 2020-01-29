import 'package:flutter/material.dart';

const blinkInterval = 10; // In seconds

enum Entity {
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

final lightTheme = {
  Entity.background: Colors.white,
  Entity.indications: Colors.grey,
  Entity.leaf: Colors.lightGreen,
  Entity.tongue: Colors.red.shade700,
  Entity.eyes: Colors.black,
  Entity.body: null,
  Entity.spring: Colors.green.shade400,
  Entity.summer: Colors.amber.shade200,
  Entity.fall: Colors.orange,
  Entity.winter: Colors.blue.shade300,
};

final darkTheme = {
  Entity.background: Colors.black,
  Entity.indications: Colors.grey,
  Entity.leaf: Colors.lightGreen,
  Entity.tongue: Colors.red.shade700,
  Entity.eyes: Colors.black,
  Entity.body: null,
  Entity.spring: Colors.green.shade400,
  Entity.summer: Colors.amber.shade200,
  Entity.fall: Colors.orange,
  Entity.winter: Colors.blue.shade300,
};

enum Season {
  spring,
  summer,
  fall,
  winter,
}

final seasons = {
  Season.spring: DateTime(0, 3, 1),
  Season.summer: DateTime(0, 6, 1),
  Season.fall: DateTime(0, 9, 1),
  Season.winter: DateTime(0, 12, 1),
};

enum Apple {
  red,
  green,
  yellow,
}
