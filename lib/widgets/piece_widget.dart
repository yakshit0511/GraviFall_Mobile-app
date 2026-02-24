import 'package:flutter/material.dart';
import '../models/models.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double blockSize;

  const PieceWidget({
    Key? key,
    required this.piece,
    required this.blockSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(piece.rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(piece.cols, (c) {
            bool isSolid = piece.shape[r][c] == 1;
            return SizedBox(
              width: blockSize,
              height: blockSize,
              child: isSolid ? Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: piece.color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: piece.color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: piece.color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ) : const SizedBox.shrink(),
            );
          }),
        );
      }),
    );
  }
}
