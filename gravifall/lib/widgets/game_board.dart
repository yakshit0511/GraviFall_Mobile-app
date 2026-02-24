import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameBoardWidget extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onCellTap;

  const GameBoardWidget({
    Key? key,
    required this.gameState,
    required this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0, // perfect square for the 8x8 grid
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white24, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
             )
          ]
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cellSize = constraints.maxWidth / GameState.cols;

            return Stack(
              children: [
                // 1. the empty grid lines
                _buildGridLines(cellSize),
                
                // 2. The placed blocks
                _buildBlocks(cellSize),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridLines(double cellSize) {
    return Column(
      children: List.generate(GameState.rows, (r) {
        return Row(
          children: List.generate(GameState.cols, (c) {
            return GestureDetector(
              onTap: () => onCellTap(r, c),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildBlocks(double cellSize) {
    List<Widget> blockWidgets = [];

    for (int r = 0; r < GameState.rows; r++) {
      for (int c = 0; c < GameState.cols; c++) {
        Block? block = gameState.board[r][c];
        if (block != null) {
          blockWidgets.add(
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300), // Slide animation duration
              curve: Curves.easeOutBack,
              left: c * cellSize,
              top: r * cellSize,
              width: cellSize,
              height: cellSize,
              child: GestureDetector(
                 onTap: () => onCellTap(r, c), // Still allow tapping the cell even if a block is there (might be invalid placement, handled by state)
                 child: Container(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: block.color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                           BoxShadow(
                              color: block.glowColor.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                           )
                        ],
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                    ),
                 ),
              ),
            ),
          );
        }
      }
    }

    return Stack(children: blockWidgets);
  }
}
