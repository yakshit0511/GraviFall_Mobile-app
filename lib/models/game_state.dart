import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';

class GameState extends ChangeNotifier {
  static const int rows = 8;
  static const int cols = 8;
  static const int shiftInterval = 3;

  List<List<Color?>> board = List.generate(rows, (_) => List.filled(cols, null));
  
  int score = 0;
  int comboMultiplier = 1;
  int piecesPlaced = 0;
  int piecesPlacedSinceShift = 0;
  int bestScore = 0;
  
  Direction currentGravity = Direction.down;
  
  List<Piece> upcomingPieces = [];
  int? selectedPieceIndex;

  // For hover previews
  int? hoveredPieceIndex;
  int? hoveredRow;
  int? hoveredCol;

  bool isGameOver = false;

  final Random _random = Random();

  GameState() {
    _generateUpcomingPieces();
  }

  void _generateUpcomingPieces() {
    while (upcomingPieces.length < 3) {
      upcomingPieces.add(pieceCatalog[_random.nextInt(pieceCatalog.length)]);
    }
  }

  void selectPiece(int index) {
    if (isGameOver || index < 0 || index >= upcomingPieces.length) return;
    if (selectedPieceIndex == index) {
      selectedPieceIndex = null; // deselect
    } else {
      selectedPieceIndex = index;
    }
    notifyListeners();
  }

  void setHoveredIndex(int? pieceIndex, int? row, int? col) {
    if (hoveredPieceIndex == pieceIndex && hoveredRow == row && hoveredCol == col) return;
    hoveredPieceIndex = pieceIndex;
    hoveredRow = row;
    hoveredCol = col;
    notifyListeners();
  }

  bool isCellInHoverPreview(int r, int c) {
    if (hoveredPieceIndex == null || hoveredRow == null || hoveredCol == null) return false;
    if (hoveredPieceIndex! < 0 || hoveredPieceIndex! >= upcomingPieces.length) return false;
    
    Piece piece = upcomingPieces[hoveredPieceIndex!];
    
    // Only show preview if the placement is actually valid
    if (!canPlacePiece(piece, hoveredRow!, hoveredCol!)) return false;

    // Check if the given (r, c) falls within the piece's shape relative to (hoveredRow, hoveredCol)
    int pieceR = r - hoveredRow!;
    int pieceC = c - hoveredCol!;

    if (pieceR >= 0 && pieceR < piece.rows && pieceC >= 0 && pieceC < piece.cols) {
      return piece.shape[pieceR][pieceC] == 1;
    }
    return false;
  }

  bool canPlacePiece(Piece piece, int startRow, int startCol) {
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.shape[r][c] == 1) {
          int boardRow = startRow + r;
          int boardCol = startCol + c;
          
          if (boardRow < 0 || boardRow >= rows || boardCol < 0 || boardCol >= cols) {
            return false;
          }
          if (board[boardRow][boardCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePieceByIndex(int index, int startRow, int startCol) {
    if (isGameOver || index < 0 || index >= upcomingPieces.length) return;
    
    Piece piece = upcomingPieces[index];
    
    if (!canPlacePiece(piece, startRow, startCol)) return;

    // 1. Temporarily place the piece to allow it to slide cohesively
    // Actually, to slide it cohesively as one piece without breaking its shape,
    // we need to find how far the ENTIRE piece can slide.
    int slideDistance = _calculatePieceSlideDistance(piece, startRow, startCol);
    
    int finalRow = startRow;
    int finalCol = startCol;

    switch (currentGravity) {
      case Direction.down: finalRow += slideDistance; break;
      case Direction.up: finalRow -= slideDistance; break;
      case Direction.left: finalCol -= slideDistance; break;
      case Direction.right: finalCol += slideDistance; break;
    }

    // Lock it into the board
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.shape[r][c] == 1) {
          board[finalRow + r][finalCol + c] = piece.color;
        }
      }
    }

    // Update state
    upcomingPieces.removeAt(index);
    selectedPieceIndex = null;
    piecesPlaced++;
    piecesPlacedSinceShift++;
    
    int pieceSize = 0;
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.shape[r][c] == 1) pieceSize++;
      }
    }
    score += pieceSize * 10; // 10 pts per block in the piece

    if (upcomingPieces.isEmpty) {
      _generateUpcomingPieces();
    }

    // 2. Check line clears
    bool cleared = _checkLineClears();
    if (!cleared) {
      comboMultiplier = 1; // reset combo
    }

    // 3. Shift gravity if needed
    if (piecesPlacedSinceShift >= shiftInterval) {
      _shiftGravity();
    }

    // 4. Check game over
    _checkGameOver();

    notifyListeners();
  }

  int _calculatePieceSlideDistance(Piece piece, int startRow, int startCol) {
    int maxSlide = 0;
    while (true) {
      int nextRow = startRow;
      int nextCol = startCol;
      switch (currentGravity) {
        case Direction.down: nextRow += maxSlide + 1; break;
        case Direction.up: nextRow -= maxSlide + 1; break;
        case Direction.left: nextCol -= maxSlide + 1; break;
        case Direction.right: nextCol += maxSlide + 1; break;
      }

      // Check if it fits at (nextRow, nextCol)
      if (canPlacePiece(piece, nextRow, nextCol)) {
        maxSlide++;
      } else {
        break;
      }
    }
    return maxSlide;
  }

  bool _checkLineClears() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Check rows
    for (int r = 0; r < rows; r++) {
      bool full = true;
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) rowsToClear.add(r);
    }

    // Check columns
    for (int c = 0; c < cols; c++) {
      bool full = true;
      for (int r = 0; r < rows; r++) {
        if (board[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) colsToClear.add(c);
    }

    int totalLines = rowsToClear.length + colsToClear.length;
    if (totalLines == 0) return false;

    // Clear the lines
    for (int r in rowsToClear) {
      for (int c = 0; c < cols; c++) {
        board[r][c] = null;
      }
    }
    for (int c in colsToClear) {
      for (int r = 0; r < rows; r++) {
        board[r][c] = null;
      }
    }

    // Calculate score
    int points = totalLines * 100;

    points = (points * comboMultiplier).toInt();
    if (currentGravity != Direction.down) {
      points *= 2; // Anti-gravity bonus
    }

    score += points;
    
    // Increase combo significantly for consecutive clears
    comboMultiplier += 1; 

    return true;
  }

  void _shiftGravity() {
    piecesPlacedSinceShift = 0;
    // Rotate gravity
    switch (currentGravity) {
      case Direction.down: currentGravity = Direction.left; break;
      case Direction.left: currentGravity = Direction.up; break;
      case Direction.up: currentGravity = Direction.right; break;
      case Direction.right: currentGravity = Direction.down; break;
    }

    _slideAllBlocks();
    
    // Check for line clears after slide
    _checkLineClears();
  }

  void _slideAllBlocks() {
    // Collect all blocks
    List<Map<String, dynamic>> blocks = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] != null) {
          blocks.add({'row': r, 'col': c, 'color': board[r][c]});
          board[r][c] = null; // Clear board temporarily
        }
      }
    }

    // Sort blocks based on gravity so ones closest to the wall move first
    if (currentGravity == Direction.down) {
      blocks.sort((a, b) => b['row'].compareTo(a['row']));
    } else if (currentGravity == Direction.up) {
      blocks.sort((a, b) => a['row'].compareTo(b['row']));
    } else if (currentGravity == Direction.right) {
      blocks.sort((a, b) => b['col'].compareTo(a['col']));
    } else if (currentGravity == Direction.left) {
      blocks.sort((a, b) => a['col'].compareTo(b['col']));
    }

    // Place and slide each block
    for (var block in blocks) {
      int r = block['row'];
      int c = block['col'];
      Color color = block['color'];

      while (true) {
        int nextR = r;
        int nextC = c;
        switch (currentGravity) {
          case Direction.down: nextR++; break;
          case Direction.up: nextR--; break;
          case Direction.right: nextC++; break;
          case Direction.left: nextC--; break;
        }

        if (nextR < 0 || nextR >= rows || nextC < 0 || nextC >= cols || board[nextR][nextC] != null) {
          break; // Hit a wall or block
        }
        r = nextR;
        c = nextC;
      }

      board[r][c] = color;
    }
  }

  void _checkGameOver() {
    // If ANY of the upcoming pieces can be placed ANYWHERE, it's not game over.
    for (var piece in upcomingPieces) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (canPlacePiece(piece, r, c)) {
            return; // Found a valid spot
          }
        }
      }
    }
    
    isGameOver = true;
    if (score > bestScore) {
      bestScore = score;
    }
  }

  void resetGame() {
    board = List.generate(rows, (_) => List.filled(cols, null));
    score = 0;
    comboMultiplier = 1;
    piecesPlaced = 0;
    piecesPlacedSinceShift = 0;
    currentGravity = Direction.down;
    upcomingPieces.clear();
    selectedPieceIndex = null;
    isGameOver = false;
    _generateUpcomingPieces();
    notifyListeners();
  }
}
