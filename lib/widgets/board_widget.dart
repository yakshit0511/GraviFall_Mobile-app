import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF283457), // Slightly darker blue grid background
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4A5C8E), width: 2),
        ),
        child: Consumer<GameState>(
          builder: (context, state, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = constraints.maxWidth / GameState.cols;
                
                return DragTarget<int>(
                  onWillAcceptWithDetails: (details) => true,
                  onMove: (details) {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    Offset localPos = box.globalToLocal(details.offset);
                    
                    Piece piece = state.upcomingPieces[details.data];
                    
                    // The offset used in GameScreen to float the piece
                    Offset pieceTopLeft = localPos + Offset(-cellSize / 2, -cellSize * piece.rows - 20);
                    
                    int r = (pieceTopLeft.dy / cellSize).round();
                    int c = (pieceTopLeft.dx / cellSize).round();
                    
                    state.setHoveredIndex(details.data, r, c);
                  },
                  onAcceptWithDetails: (details) {
                    if (state.hoveredRow != null && state.hoveredCol != null) {
                      state.placePieceByIndex(details.data, state.hoveredRow!, state.hoveredCol!);
                    }
                    state.setHoveredIndex(null, null, null);
                  },
                  onLeave: (_) => state.setHoveredIndex(null, null, null),
                  builder: (context, candidateData, rejectedData) {
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: GameState.cols,
                      ),
                      itemCount: GameState.rows * GameState.cols,
                      itemBuilder: (context, index) {
                        int row = index ~/ GameState.cols;
                        int col = index % GameState.cols;
                        Color? cellColor = state.board[row][col];
                        
                        bool isHoveredPart = state.isCellInHoverPreview(row, col);
                        
                        // Solid grey block preview exactly matching screenshots
                        Widget? innerChild;
                        if (cellColor != null) {
                          innerChild = _buildBlockInner(cellColor);
                        } else if (isHoveredPart) {
                          innerChild = _buildBlockInner(const Color(0xFF707A94)); 
                        }

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF384976), width: 0.5),
                          ),
                          margin: const EdgeInsets.all(1),
                          child: innerChild,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlockInner(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }

}
