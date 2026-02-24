import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import '../widgets/gravity_compass.dart';
import '../widgets/piece_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF384976), // Deep blue theme from screenshot
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context),
                const Expanded(
                  child: Center(
                    child: BoardWidget(),
                  ),
                ),
                _buildUpcomingPieces(context),
                const SizedBox(height: 20),
              ],
            ),
            _buildGameOverOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        if (!state.isGameOver) return const SizedBox.shrink();

        return Container(
          color: const Color(0xFF6B3FA0).withOpacity(0.95), // Bright purple matching screenshot
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Best Score!',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Score',
                style: TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  state.resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score Display
          Consumer<GameState>(
            builder: (context, state, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${state.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (state.comboMultiplier > 1)
                    Text(
                      '${state.comboMultiplier}x COMBO!',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Gravity Compass
          const GravityCompass(),
        ],
      ),
    );
  }

  Widget _buildUpcomingPieces(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // The board taking up AspectRatio(1) with 16 margin on both sides means:
    double boardWidth = screenWidth - 32;
    double draggingBlockSize = boardWidth / GameState.cols;

    return Consumer<GameState>(
      builder: (context, state, child) {
        if (state.isGameOver) {
          return const SizedBox(height: 120); // Maintain spacing
        }

        return Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(state.upcomingPieces.length, (index) {
              final piece = state.upcomingPieces[index];
              
              return Draggable<int>(
                data: index,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Transform.translate(
                  // Offset the piece so it floats entirely UP and ABOVE the user's finger,
                  // making it very easy to see where it will land on the grid.
                  offset: Offset(-draggingBlockSize / 2, -draggingBlockSize * piece.rows - 20),
                  child: Material(
                    color: Colors.transparent,
                    child: PieceWidget(piece: piece, blockSize: draggingBlockSize),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PieceWidget(piece: piece, blockSize: 20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PieceWidget(piece: piece, blockSize: 20),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
