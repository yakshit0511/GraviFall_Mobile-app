import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/tetromino.dart';

class NextPiecesWidget extends StatelessWidget {
  final GameState gameState;
  final int? selectedPieceIndex;
  final Function(int) onPieceSelected;

  const NextPiecesWidget({
    Key? key,
    required this.gameState,
    required this.selectedPieceIndex,
    required this.onPieceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          bool isSelected = selectedPieceIndex == index;
          Tetromino piece = gameState.availablePieces[index];

          return GestureDetector(
            onTap: () => onPieceSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: piece.glowColor.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: _buildPiecePreview(piece, isSelected),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPiecePreview(Tetromino piece, bool isSelected) {
    double blockSize = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: piece.width * blockSize,
          height: piece.height * blockSize,
          child: Stack(
            children: _buildPreviewBlocks(piece, blockSize, isSelected),
          ),
        );
      }
    );
  }

  List<Widget> _buildPreviewBlocks(Tetromino piece, double blockSize, bool isSelected) {
    List<Widget> blocks = [];
    for (int r = 0; r < piece.height; r++) {
      for (int c = 0; c < piece.width; c++) {
        if (piece.shape[r][c] == 1) {
          blocks.add(
            Positioned(
              left: c * blockSize,
              top: r * blockSize,
              width: blockSize,
              height: blockSize,
              child: Container(
                margin: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(
                  color: piece.baseColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: piece.glowColor.withOpacity(isSelected ? 0.8 : 0.4),
                      blurRadius: isSelected ? 4 : 2,
                      spreadRadius: 0,
                    )
                  ],
                  border: Border.all(color: Colors.white54, width: 0.5),
                ),
              ),
            ),
          );
        }
      }
    }
    return blocks;
  }
}
