import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final Image image;
  final Rect rect;
  final int row;
  final int col;

  PuzzlePiece({
    Key? key,
    required this.image,
    required this.rect,
    required this.row,
    required this.col,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
          foregroundPainter: PuzzlePiecePainter(rect), child: image),
      clipper: PuzzlePieceClipper(rect),
    );
  }
}

// this class is used to clip the image to the puzzle piece path
class PuzzlePieceClipper extends CustomClipper<Rect> {
  final Rect rect;
  PuzzlePieceClipper(this.rect);

  @override
  Rect getClip(Size size) {
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

// this class is used to draw a border around the clipped image
class PuzzlePiecePainter extends CustomPainter {
  final Rect rect;

  PuzzlePiecePainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(Path()..addRect(rect), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
