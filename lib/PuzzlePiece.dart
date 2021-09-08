import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final ImageInfo image;
  final Rect rect;
  final Size drawSize;
  final int row;
  final int col;

  PuzzlePiece({
    Key? key,
    required this.image,
    required this.rect,
    required this.drawSize,
    required this.row,
    required this.col,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: PuzzlePiecePainter(rect, image, drawSize));
  }
}

// this class is used to draw a clipped image with border
class PuzzlePiecePainter extends CustomPainter {
  final Rect rect;
  final ImageInfo image;
  final Size drawSize;
  PuzzlePiecePainter(this.rect, this.image, this.drawSize);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(image.image, rect, Offset.zero & drawSize, Paint());
    // final Paint paint = Paint()
    //   ..color = Color(0x80FFFFFF)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0;
    // canvas.drawPath(Path()..addRect(rect), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
