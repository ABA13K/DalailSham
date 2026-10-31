import 'package:flutter/material.dart';

/// Circular company mark: the initial letter with a category icon badge.
class PlaceLogoMark extends StatelessWidget {
  const PlaceLogoMark({
    super.key,
    required this.initial,
    required this.gradient,
    required this.icon,
    this.size = 84,
  });

  final String initial;
  final Gradient gradient;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final badge = size * 0.36;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.036),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -2,
            end: -2,
            child: Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: badge * 0.57,
                color: Color.lerp(gradient.colors.last, Colors.black, 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
