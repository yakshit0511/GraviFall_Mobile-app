import 'package:flutter/material.dart';
import '../models/game_state.dart';

class HeaderWidget extends StatelessWidget {
  final GameState gameState;

  const HeaderWidget({Key? key, required this.gameState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(Icons.military_tech, color: Colors.amber, size: 28),
                   SizedBox(width: 8),
                   Text(
                    '${gameState.score}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (gameState.comboMultiplier > 1.0)
                Text(
                  '${gameState.comboMultiplier}x COMBO!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
            ],
          ),

          // Gravity Compass
          _GravityCompass(direction: gameState.currentGravity, piecesSinceShift: gameState.piecesSinceLastShift),
        ],
      ),
    );
  }
}

class _GravityCompass extends StatelessWidget {
  final GravityDirection direction;
  final int piecesSinceShift;

  const _GravityCompass({required this.direction, required this.piecesSinceShift});

  double _getRotationAngles() {
    switch (direction) {
      case GravityDirection.down: return 0.0;
      case GravityDirection.left: return 90.0 * 3.14159 / 180; // 90 deg clockwise (so arrow points down/left?)
      // Actually standard rotation: 
      // 0 = Down (let's say arrow points DOWN)
      // Left = arrow points Left (-90 or 270)
      // Up = arrow points Up (180)
      // Right = arrow points Right (90)
           
       }
       switch (direction) {
         case GravityDirection.down: return 0.0;
         case GravityDirection.left: return 90.0 * 3.14159 / 180;
         case GravityDirection.up: return 180.0 * 3.14159 / 180;
         case GravityDirection.right: return 270.0 * 3.14159 / 180;
       }
  }

  @override
  Widget build(BuildContext context) {
    bool isWarning = piecesSinceShift == 2; // Next piece triggers shift
    
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: isWarning ? Colors.redAccent : Colors.white30,
          width: isWarning ? 3.0 : 1.0,
        ),
      ),
      child: Center(
        child: TweenAnimationBuilder(
           duration: Duration(milliseconds: 500),
           tween: Tween<double>(begin: _getRotationAngles(), end: _getRotationAngles()),
           builder: (context, double value, child) {
              return Transform.rotate(
                angle: value,
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: isWarning ? Colors.redAccent : Colors.cyanAccent,
                  size: 40,
                ),
              );
           }
        ),
      ),
    );
  }
}
