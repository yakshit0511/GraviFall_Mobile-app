import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/header.dart';
import '../widgets/next_pieces.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  int? _selectedPieceIndex;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _gameState.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      // Rebuild on state change
      if (_gameState.isGameOver) {
         _showGameOverDialog();
      }
    });
  }

  void _onPieceSelected(int index) {
    setState(() {
      _selectedPieceIndex = _selectedPieceIndex == index ? null : index;
    });
  }

  void _onCellTap(int row, int col) {
    if (_selectedPieceIndex == null) return;
    
    // Attempt to place
    bool success = _gameState.placePiece(_selectedPieceIndex!, row, col);
    if (success) {
      setState(() {
        _selectedPieceIndex = null; // deselect on successful placement
      });
    } else {
       // Visual feedback for invalid placement could be added here (e.g., a quick flash or shake)
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Game Over!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
             "No more moves available.\n\nFinal Score: ${_gameState.score}",
             style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                   _gameState.resetGame();
                   _selectedPieceIndex = null;
                });
              },
              child: Text("Restart", style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          // Optional: Add a subtle starfield background image here
          decoration: BoxDecoration(
            gradient: RadialGradient(
               colors: [Color(0xFF1a1a2e), Colors.black],
               center: Alignment.center,
               radius: 1.5,
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderWidget(gameState: _gameState),
              
              Expanded(
                child: Center(
                  child: GameBoardWidget(
                     gameState: _gameState,
                     onCellTap: _onCellTap,
                  ),
                ),
              ),

              NextPiecesWidget(
                 gameState: _gameState,
                 selectedPieceIndex: _selectedPieceIndex,
                 onPieceSelected: _onPieceSelected,
              ),
              
              SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
