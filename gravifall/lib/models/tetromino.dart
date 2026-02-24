import 'package:flutter/material.dart';

enum GravityDirection { down, left, up, right }

class Tetromino {
  final List<List<int>> shape; // 2D array representation (1s and 0s)
  final Color baseColor;
  final Color glowColor;

  const Tetromino({
    required this.shape,
    required this.baseColor,
    required this.glowColor,
  });

  // Calculate width and height in blocks
  int get width => shape.isNotEmpty ? shape[0].length : 0;
  int get height => shape.length;
}

class Shapes {
  static const List<Tetromino> all = [
    // 1x1 Dot
    Tetromino(
      shape: [[1]],
      baseColor: Colors.purpleAccent,
      glowColor: Color(0xFFE040FB),
    ),
    // 2x2 Square
    Tetromino(
      shape: [
        [1, 1],
        [1, 1]
      ],
      baseColor: Colors.yellowAccent,
      glowColor: Color(0xFFFFFF00),
    ),
    // 1x3 Line H
    Tetromino(
      shape: [[1, 1, 1]],
      baseColor: Colors.cyanAccent,
      glowColor: Color(0xFF18FFFF),
    ),
    // 1x3 Line V
     Tetromino(
      shape: [
        [1],
        [1],
        [1]
      ],
      baseColor: Colors.cyanAccent,
      glowColor: Color(0xFF18FFFF),
    ),
    // 1x4 Line H
    Tetromino(
      shape: [[1, 1, 1, 1]],
      baseColor: Colors.cyan,
      glowColor: Color(0xFF00BDE3),
    ),
    // 1x4 Line V
    Tetromino(
      shape: [
        [1],
        [1],
        [1],
        [1]
      ],
      baseColor: Colors.cyan,
      glowColor: Color(0xFF00BDE3),
    ),
    // L Shape 1
    Tetromino(
      shape: [
        [1, 0],
        [1, 0],
        [1, 1]
      ],
      baseColor: Colors.deepOrangeAccent,
      glowColor: Color(0xFFFF6E40),
    ),
    // L Shape 2
    Tetromino(
      shape: [
        [0, 1],
        [0, 1],
        [1, 1]
      ],
      baseColor: Colors.orangeAccent,
      glowColor: Color(0xFFFFAB40),
    ),
    // T Shape
    Tetromino(
      shape: [
        [0, 1, 0],
        [1, 1, 1]
      ],
      baseColor: Colors.greenAccent,
      glowColor: Color(0xFF69F0AE),
    ),
    // T Shape inverted
    Tetromino(
      shape: [
        [1, 1, 1],
        [0, 1, 0]
      ],
      baseColor: Colors.greenAccent,
      glowColor: Color(0xFF69F0AE),
    ),
    // Small L
    Tetromino(
      shape: [
        [1, 0],
        [1, 1]
      ],
      baseColor: Colors.pinkAccent,
      glowColor: Color(0xFFFF4081),
    ),
     // Small L inverted
    Tetromino(
      shape: [
        [1, 1],
        [0, 1]
      ],
      baseColor: Colors.pinkAccent,
      glowColor: Color(0xFFFF4081),
    ),
     // Small L right
    Tetromino(
      shape: [
        [1, 1],
        [1, 0]
      ],
      baseColor: Colors.pinkAccent,
      glowColor: Color(0xFFFF4081),
    ),
  ];
}
