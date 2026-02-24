import 'dart:math';
import 'package:flutter/material.dart';
import 'tetromino.dart';

class Block {
  final Color color;
  final Color glowColor;
  bool isLocked;

  Block({required this.color, required this.glowColor, this.isLocked = true});
}

class GameState extends ChangeNotifier {
  static const int rows = 8;
  static const int cols = 8;
  
  // The board represented as a 2D list of nullable Blocks
  List<List<Block?>> board;
  
  // Available pieces to choose from
  List<Tetromino> availablePieces = [];
  
  int score = 0;
  double comboMultiplier = 1.0;
  int piecesPlacedCount = 0;
  int piecesSinceLastShift = 0;
  
  GravityDirection currentGravity = GravityDirection.down;
  bool isGameOver = false;

  final Random _random = Random();

  GameState() : board = List.generate(rows, (_) => List.generate(cols, (_) => null)) {
    _generateInitialPieces();
  }

  void _generateInitialPieces() {
    availablePieces = [
      _getRandomPiece(),
      _getRandomPiece(),
      _getRandomPiece(),
    ];
    notifyListeners();
  }

  Tetromino _getRandomPiece() {
    return Shapes.all[_random.nextInt(Shapes.all.length)];
  }

  void resetGame() {
    board = List.generate(rows, (_) => List.generate(cols, (_) => null));
    score = 0;
    comboMultiplier = 1.0;
    piecesPlacedCount = 0;
    piecesSinceLastShift = 0;
    currentGravity = GravityDirection.down;
    isGameOver = false;
    _generateInitialPieces();
  }

  // Check if a piece can be placed at the given row/col
  bool canPlacePiece(Tetromino piece, int startRow, int startCol) {
    if (startRow < 0 ||
        startCol < 0 ||
        startRow + piece.height > rows ||
        startCol + piece.width > cols) {
      return false;
    }

    for (int r = 0; r < piece.height; r++) {
      for (int c = 0; c < piece.width; c++) {
        if (piece.shape[r][c] == 1) {
          if (board[startRow + r][startCol + c] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Attempt to place piece and trigger slide
  bool placePiece(int pieceIndex, int startRow, int startCol) {
    if (isGameOver) return false;
    
    Tetromino piece = availablePieces[pieceIndex];
    if (!canPlacePiece(piece, startRow, startCol)) return false;

    // Temporary list to hold the newly placed blocks to slide them together
    List<Map<String, int>> newBlockPositions = [];

    for (int r = 0; r < piece.height; r++) {
      for (int c = 0; c < piece.width; c++) {
        if (piece.shape[r][c] == 1) {
          int bRow = startRow + r;
          int bCol = startCol + c;
          board[bRow][bCol] = Block(
            color: piece.baseColor,
            glowColor: piece.glowColor,
          );
          newBlockPositions.add({'r': bRow, 'c': bCol});
        }
      }
    }
    
    // Add base placement point
    score += (1 * comboMultiplier).toInt();
    
    // Slide the newly placed pieces IMMEDIATELY
    _slideBlocks(newBlockPositions, currentGravity);

    piecesPlacedCount++;
    piecesSinceLastShift++;

    // Generate new piece to replace used one
    availablePieces[pieceIndex] = _getRandomPiece();

    // Check for gravity shift every 3 pieces
    if (piecesSinceLastShift >= 3) {
      piecesSinceLastShift = 0;
      _shiftGravity();
    } else {
      // If no shift, check for clears directly after slide
      _checkAndClearLines();
    }
    
    _checkGameOver();
    notifyListeners();
    return true;
  }

  void _shiftGravity() {
    int nextDirIndex = (currentGravity.index + 1) % GravityDirection.values.length;
    currentGravity = GravityDirection.values[nextDirIndex];
    
    // Slide ALL blocks on board towards new gravity
    _slideAllBlocks();
    
    // Check clears after everything settles
    _checkAndClearLines();
  }

  void _slideAllBlocks() {
    // Need to iterate in the correct order so blocks don't block each other incorrectly during the slide
    // E.g., if sliding DOWN, slide bottom row first.
    List<Map<String, int>> allBlockPositions = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] != null) {
          allBlockPositions.add({'r': r, 'c': c});
        }
      }
    }
    
    // Sort blocks by distance to the target wall so the closest ones slide first
    allBlockPositions.sort((a, b) {
       switch (currentGravity) {
        case GravityDirection.down: return b['r']!.compareTo(a['r']!); // Largest R first (bottom)
        case GravityDirection.up: return a['r']!.compareTo(b['r']!);   // Smallest R first (top)
        case GravityDirection.left: return a['c']!.compareTo(b['c']!); // Smallest C first (left)
        case GravityDirection.right: return b['c']!.compareTo(a['c']!); // Largest C first (right)
      }
    });

    for (var pos in allBlockPositions) {
      _slideBlocks([pos], currentGravity);
    }
  }

  void _slideBlocks(List<Map<String, int>> positions, GravityDirection dir) {
    // Determine movement deltas
    int dr = 0, dc = 0;
    switch (dir) {
      case GravityDirection.down: dr = 1; break;
      case GravityDirection.up: dr = -1; break;
      case GravityDirection.left: dc = -1; break;
      case GravityDirection.right: dc = 1; break;
    }

    bool canMove = true;
    while (canMove) {
      canMove = false;
      bool allCanMoveOneStep = true;
      
      // Check if ALL blocks in the group can move one step
      for (var p in positions) {
        int r = p['r']!;
        int c = p['c']!;
        int nr = r + dr;
        int nc = c + dc;
        
        // Blocked by wall
        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) {
          allCanMoveOneStep = false;
          break;
        }
        
        // Blocked by another block NOT in the sliding group
        if (board[nr][nc] != null) {
          bool isInsideGroup = false;
          for (var otherP in positions) {
             if (otherP['r'] == nr && otherP['c'] == nc) {
                isInsideGroup = true;
                break;
             }
          }
          if (!isInsideGroup) {
             allCanMoveOneStep = false;
             break;
          }
        }
      }

      if (allCanMoveOneStep) {
        canMove = true;
        
        // To move all blocks, we extract them first to avoid overriding each other during shift
        List<Block> extractedBlocks = [];
        for (var p in positions) {
            extractedBlocks.add(board[p['r']!]?[p['c']!] as Block);
            board[p['r']!][p['c']!] = null; // Clear old pos
        }
        
        for (int i=0; i < positions.length; i++) {
           positions[i]['r'] = positions[i]['r']! + dr;
           positions[i]['c'] = positions[i]['c']! + dc;
           board[positions[i]['r']!][positions[i]['c']!] = extractedBlocks[i];
        }
      }
    }
  }

  void _checkAndClearLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Check Rows
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

    // Check Cols
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

    int linesCleared = rowsToClear.length + colsToClear.length;

    if (linesCleared > 0) {
      // Clear them
      for (int r in rowsToClear) {
        for (int c = 0; c < cols; c++) board[r][c] = null;
      }
      for (int c in colsToClear) {
        for (int r = 0; r < rows; r++) board[r][c] = null;
      }

      // Calculate score
      int baseScore = 0;
      if (linesCleared == 1) baseScore = 10;
      else if (linesCleared == 2) baseScore = 25;
      else if (linesCleared >= 3) baseScore = 50; // + "GRAVIBURST" visual effect eventually

      // Anti-gravity bonus
      if (currentGravity != GravityDirection.down) {
         baseScore *= 2;
      }
      
      score += (baseScore * comboMultiplier).toInt();
      comboMultiplier += 0.5; // Increment combo
    } else {
      comboMultiplier = 1.0; // Reset combo if no clear
    }
  }

  void _checkGameOver() {
    // If NO available piece can be placed ANYWHERE, game over
    bool canPlaceAny = false;
    for (var piece in availablePieces) {
      for (int r = 0; r <= rows - piece.height; r++) {
        for (int c = 0; c <= cols - piece.width; c++) {
           if (canPlacePiece(piece, r, c)) {
              canPlaceAny = true;
              break;
           }
        }
        if (canPlaceAny) break;
      }
      if (canPlaceAny) break;
    }
    
    if (!canPlaceAny) {
      isGameOver = true;
    }
  }
}
