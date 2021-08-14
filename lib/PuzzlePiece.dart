import 'dart:math';

import 'package:flutter/material.dart';

class PuzzlePiece extends StatefulWidget {
  final Image image;
  final Size imageSize;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final Function bringToTop;

  PuzzlePiece(
      {Key? key,
      required this.image,
      required this.imageSize,
      required this.row,
      required this.col,
      required this.maxRow,
      required this.maxCol,
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
    final imageWidth = MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).size.width /
        widget.imageSize.width;
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

              if (-10 < top! && top! < 10 && -10 < left! && left! < 10) {
                top = 0;
                left = 0;
                isMovable = false;
              }
            });
          }
        },
        child: ClipPath(
          child: widget.image,
          // child:  CustomPaint(
          // foregroundPainter: PuzzlePiecePainter(
          //     widget.row, widget.col, widget.maxRow, widget.maxCol),
          //child: widget.image),
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

// // this class is used to draw a border around the clipped image
// class PuzzlePiecePainter extends CustomPainter {
//   final int row;
//   final int col;
//   final int maxRow;
//   final int maxCol;

//   PuzzlePiecePainter(this.row, this.col, this.maxRow, this.maxCol);

//   @override
//   void paint(Canvas canvas, Size size) {
//   final Paint paint = Paint()
//     ..color = Color(0x80FFFFFF)
//     ..style = PaintingStyle.stroke
//     ..strokeWidth = 1.0;

//   canvas.drawPath(getPiecePath(size, row, col, maxRow, maxCol), paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

// this is the path used to clip the image and, then, to draw a border around it; here we actually draw the puzzle piece
Path getPiecePath(Size size, int row, int col, int maxRow, int maxCol) {
  final width = size.width / maxCol;
  final height = size.height / maxRow;
  final offsetX = col * width;
  final offsetY = row * height;

  var path = Path();
  path.moveTo(offsetX, offsetY);

  path.lineTo(offsetX + width, offsetY);
  path.lineTo(offsetX + width, offsetY + height);
  path.lineTo(offsetX, offsetY + height);

  path.close();

  return path;
}
