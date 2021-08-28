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

class _DragMode {
  bool isRow; //! whether we're dragging rows or columnns
  int idx; //! the row/column we're dragging
  _DragMode({required this.isRow, required this.idx});
}

class _MyPuzzleAreaState extends State<PuzzleArea> {
  List rowPos;
  List colPos;
  List<PuzzlePiece> pieces;
  _DragMode? dm;
  Offset dragOff = Offset.zero;

  _MyPuzzleAreaState({required this.pieces, required Size ps})
      : rowPos = List.generate(PuzzleArea.rows, (i) => i * ps.height),
        colPos = List.generate(PuzzleArea.cols, (i) => i * ps.width);

  Offset dragEffect(int r, int c) {
    final ldm = dm;
    if (ldm == null) return Offset.zero;
    if (ldm.isRow) {
      if (r != ldm.idx) return Offset.zero;
      return Offset(0, dragOff.dy);
    } else {
      if (c != ldm.idx) return Offset.zero;
      return Offset(dragOff.dx, 0);
    }
  }

  @override
  build(BuildContext context) {
    final Size contextSize = MediaQuery.of(context).size;
    final Size imageSize = widget.imageSize;
    final fitScale = min<double>(contextSize.width / imageSize.width,
        contextSize.height / imageSize.height);
    final imageWidth = contextSize.width * fitScale;
    // final imageHeight = contextSize.height * fitScale;
    final placePiece = (PuzzlePiece w) => Positioned(
        top: (rowPos[w.row] - w.rect.top) * fitScale +
            dragEffect(w.row, w.col).dy,
        left: (colPos[w.col] - w.rect.left) * fitScale +
            dragEffect(w.row, w.col).dx,
        width: imageWidth,
        child: GestureDetector(
          onPanUpdate: (dragUpdateDetails) {
            const thresh = 10; // min pixels to drag to determine direction
            setState(() {
              dragOff += dragUpdateDetails.delta;
              if (dm == null &&
                  (dragOff.dx.abs() > thresh || dragOff.dy.abs() > thresh)) {
                final isRow = dragOff.dx.abs() < dragOff.dy.abs();
                dm = _DragMode(isRow: isRow, idx: isRow ? w.row : w.col);
              }
            });
          },
          onPanEnd: (dragEndDetails) {
            // recompute row positions
            final de = dragEffect(w.row, w.col);
            rowPos[w.row] += de.dy;
            colPos[w.col] += de.dx;
            // TODO: re-snap coordinates to grid

            // reset drag state
            dm = null;
            dragOff = Offset.zero;
          },
          child: w,
        ));
    final p2 = pieces.map(placePiece).toList();
    return Stack(children: p2);
  }
}
