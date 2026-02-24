import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';

class GravityCompass extends StatelessWidget {
  const GravityCompass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        int turnsLeft = GameState.shiftInterval - state.piecesPlacedSinceShift;
        bool isWarning = turnsLeft == 1;

        double rotation = 0;
        switch (state.currentGravity) {
          case Direction.down: rotation = 0; break;
          case Direction.left: rotation = 3.14159 / 2; break; // 90 deg clockwise -> wait, left is 90 deg rotation of DOWN arrow? No, right is 90 deg clockwise.
          // Wait, if arrow points down, left means point left, which is 90 deg CLOCKWISE from down
          case Direction.up: rotation = 3.14159; break;
          case Direction.right: rotation = -3.14159 / 2; break;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(
              color: isWarning ? Colors.redAccent : Colors.cyanAccent,
              width: 2,
            ),
            boxShadow: isWarning
                ? [
                    const BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GRAVITY',
                style: TextStyle(
                  color: isWarning ? Colors.redAccent : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedRotation(
                turns: rotation / (2 * 3.14159), // Converting radians to turns
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: isWarning ? Colors.redAccent : Colors.cyanAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$turnsLeft TURN${turnsLeft == 1 ? '' : 'S'}',
                style: TextStyle(
                  color: isWarning ? Colors.redAccent : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
