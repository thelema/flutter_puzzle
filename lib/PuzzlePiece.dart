import 'dart:math';

import 'package:flutter/material.dart';

class PuzzlePiece extends StatefulWidget {
  final Image image;
  final Size imageSize;
  final int row; // my row
  final int col; // my col
  final List<int> rowPerm; // current row permutation
  final List<int> colPerm; // current column permutation
  final Function bringToTop;

  int get maxRow => rowPerm.length;
  int get maxCol => colPerm.length;

  PuzzlePiece(
      {Key? key,
      required this.image,
      required this.imageSize,
      required this.row,
      required this.col,
      required this.rowPerm,
      required this.colPerm,
      required this.bringToTop})
      : super(key: key);

  @override
  PuzzlePieceState createState() {
    return new PuzzlePieceState();
  }
}

class PuzzlePieceState extends State<PuzzlePiece> {
  double? top;
  double? left;
  bool isMovable = true;

  @override
  Widget build(BuildContext context) {
    final Size contextSize = MediaQuery.of(context).size;
    final Size imageSize = widget.imageSize;
    final fitScale = min(contextSize.width / imageSize.width,
        contextSize.height / imageSize.height);
    final imageWidth = contextSize.width * fitScale;
    final imageHeight = contextSize.height * fitScale;
    final pieceWidth = imageWidth / widget.maxCol;
    final pieceHeight = imageHeight / widget.maxRow;

    top ??= Random().nextInt((imageHeight - pieceHeight).ceil()).toDouble() -
        widget.row * pieceHeight;
    left ??= Random().nextInt((imageWidth - pieceWidth).ceil()).toDouble() -
        widget.col * pieceWidth;

    return Positioned(
      top: top,
      left: left,
      width: imageWidth,
      child: GestureDetector(
        onPanStart: (_) {
          if (isMovable) {
            widget.bringToTop(widget);
          }
        },
        onPanUpdate: (dragUpdateDetails) {
          if (isMovable) {
            setState(() {
              top = top! + dragUpdateDetails.delta.dy;
              left = left! + dragUpdateDetails.delta.dx;
              final xsnap = 10;
              final ysnap = 10;
              if (top!.abs() < ysnap && left!.abs() < xsnap) {
                top = 0;
                left = 0;
                isMovable = false;
              }
            });
          }
        },
        child: ClipPath(
          child: CustomPaint(
              foregroundPainter: PuzzlePiecePainter(
                  widget.row, widget.col, widget.maxRow, widget.maxCol),
              child: widget.image),
          clipper: PuzzlePieceClipper(
              widget.row, widget.col, widget.maxRow, widget.maxCol),
        ),
      ),
    );
  }
}

// this class is used to clip the image to the puzzle piece path
class PuzzlePieceClipper extends CustomClipper<Path> {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  PuzzlePieceClipper(this.row, this.col, this.maxRow, this.maxCol);

  @override
  Path getClip(Size size) {
    return getPiecePath(size, row, col, maxRow, maxCol);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// this class is used to draw a border around the clipped image
class PuzzlePiecePainter extends CustomPainter {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  PuzzlePiecePainter(this.row, this.col, this.maxRow, this.maxCol);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(getPiecePath(size, row, col, maxRow, maxCol), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// this is the path used to clip the image and, then, to draw a border around it; here we actually draw the puzzle piece
Path getPiecePath(Size size, int row, int col, int maxRow, int maxCol) {
  final width = size.width / maxCol;
  final height = size.height / maxRow;
  final offsetX = col * width;
  final offsetY = row * height;

  var path = Path();
  path.addRect(Offset(offsetX, offsetY) & Size(width, height));
  return path;
}
