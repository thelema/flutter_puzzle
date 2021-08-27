import 'dart:math';

import 'PuzzlePiece.dart';

import 'package:flutter/material.dart';

class PuzzleArea extends StatefulWidget {
  static const int rows = 3;
  static const int cols = 3;
  final Image image;
  final Size imageSize;
  final Size pieceSize;

  PuzzleArea(this.image, this.imageSize)
      : pieceSize = Size(imageSize.width / cols, imageSize.height / rows);

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  static List<PuzzlePiece> splitImage(Image image, Size pieceSize) {
    List<PuzzlePiece> pieces = [];
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        final rect =
            Offset(pieceSize.width * x, pieceSize.height * y) & pieceSize;
        pieces.add(PuzzlePiece(image: image, rect: rect, col: x, row: y));
      }
    }
    return pieces;
  }

  @override
  _MyPuzzleAreaState createState() =>
      _MyPuzzleAreaState(pieces: splitImage(image, pieceSize), ps: pieceSize);
}

class _MyPuzzleAreaState extends State<PuzzleArea> {
  List rowPerm;
  List colPerm;
  List<PuzzlePiece> pieces;

  _MyPuzzleAreaState({required this.pieces, required Size ps})
      : rowPerm = List.generate(PuzzleArea.rows, (i) => i * ps.height),
        colPerm = List.generate(PuzzleArea.cols, (i) => i * ps.width);

  @override
  build(BuildContext context) {
    final Size contextSize = MediaQuery.of(context).size;
    final Size imageSize = widget.imageSize;
    final fitScale = min<double>(contextSize.width / imageSize.width,
        contextSize.height / imageSize.height);
    final imageWidth = contextSize.width * fitScale;
    // final imageHeight = contextSize.height * fitScale;
    final placePiece = (PuzzlePiece w) => Positioned(
        top: (rowPerm[w.row] - w.rect.top) * fitScale,
        left: (colPerm[w.col] - w.rect.left) * fitScale,
        width: imageWidth,
        child: GestureDetector(
          onPanUpdate: (dragUpdateDetails) {
            // setState(() {
            // top = top + dragUpdateDetails.delta.dy;
            // left = left + dragUpdateDetails.delta.dx;
            // final xsnap = 10;
            // final ysnap = 10;
            // if (top!.abs() < ysnap && left!.abs() < xsnap) {
            //   top = 0;
            //   left = 0;
            //   // isMovable = false;
            // }
            // }
          },
          onPanEnd: (dragEndDetails) {
            // recompute permutation
          },
          child: w,
        ));
    final p2 = pieces.map(placePiece).toList();
    return Stack(children: p2);
  }
}
