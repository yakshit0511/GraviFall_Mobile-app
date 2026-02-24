import 'package:flutter/material.dart';

enum Direction { down, left, up, right }

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class Piece {
  final List<List<int>> shape; // 1 for solid, 0 for empty
  final Color color;

  const Piece(this.shape, this.color);

  int get rows => shape.length;
  int get cols => shape[0].length;
}

// Pre-defined set of classic Tetris-style/Block-blast shapes
final List<Piece> pieceCatalog = [
  // 1x1 dot
  Piece([[1]], Colors.cyanAccent),
  // 2x2 square
  Piece([
    [1, 1],
    [1, 1],
  ], Colors.yellowAccent),
  // 3x3 square
  Piece([
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1],
  ], Colors.orangeAccent),
  // 1x2 vertical
  Piece([
    [1],
    [1],
  ], Colors.greenAccent),
  // 1x3 vertical
  Piece([
    [1],
    [1],
    [1],
  ], Colors.greenAccent),
  // 1x4 vertical
  Piece([
    [1],
    [1],
    [1],
    [1],
  ], Colors.greenAccent),
  // 2x1 horizontal
  Piece([[1, 1]], Colors.purpleAccent),
  // 3x1 horizontal
  Piece([[1, 1, 1]], Colors.purpleAccent),
  // 4x1 horizontal
  Piece([[1, 1, 1, 1]], Colors.purpleAccent),
  // L shape
  Piece([
    [1, 0],
    [1, 0],
    [1, 1],
  ], Colors.redAccent),
  // L shape mirrored
  Piece([
    [0, 1],
    [0, 1],
    [1, 1],
  ], Colors.redAccent),
  // Reverse L
  Piece([
    [1, 1],
    [1, 0],
    [1, 0],
  ], Colors.redAccent),
  // Reverse L mirrored
  Piece([
    [1, 1],
    [0, 1],
    [0, 1],
  ], Colors.redAccent),
  // T shape
  Piece([
    [1, 1, 1],
    [0, 1, 0],
  ], Colors.pinkAccent),
  // Z shape
  Piece([
    [1, 1, 0],
    [0, 1, 1],
  ], Colors.blueAccent),
  // S shape
  Piece([
    [0, 1, 1],
    [1, 1, 0],
  ], Colors.blueAccent),
];
