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
      _MyPuzzleAreaState(pieces: splitImage(image, pieceSize));
}

class _DragMode {
  bool isRow; //! whether we're dragging rows or columnns
  int idx; //! the row/column we're dragging
  _DragMode({required this.isRow, required this.idx});
}

class _MyPuzzleAreaState extends State<PuzzleArea> {
  List<int> rowDisp; // original row -> positioned row
  List<int> colDisp; // original col -> positioned col
  List<int> dispRow; // positioned row -> original row (inverse of rowDisp)
  List<int> dispCol; // positioned col -> original col (inverse of colDisp)
  List<PuzzlePiece> pieces;
  _DragMode? dm;
  Offset dragOff = Offset.zero;

  _MyPuzzleAreaState({required this.pieces})
      : rowDisp = List.generate(PuzzleArea.rows, (i) => i),
        colDisp = List.generate(PuzzleArea.cols, (i) => i),
        dispRow = List.generate(PuzzleArea.rows, (i) => i),
        dispCol = List.generate(PuzzleArea.cols, (i) => i); //TODO: shuffle

  static void swapEntries(List<int> perm, List<int> inv, int i, int j) {
    final temp = perm[i];
    perm[i] = perm[j];
    perm[j] = temp;
    // fix up inverse function
    inv[perm[j]] = j;
    inv[perm[i]] = i;
  }

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
    // final Size contextSize = MediaQuery.of(context).size;
    final Size imageSize = widget.imageSize;
    final double fitScale = 1.0;
    //min<double>(contextSize.width / imageSize.width,
    // contextSize.height / imageSize.height);
    final imageWidth = imageSize.width * fitScale;
    // final imageHeight = contextSize.height * fitScale;
    final placePiece = (PuzzlePiece w) => Positioned(
        top:
            (rowDisp[w.row] * widget.pieceSize.height - w.rect.top) * fitScale +
                dragEffect(w.row, w.col).dy,
        left:
            (colDisp[w.col] * widget.pieceSize.width - w.rect.left) * fitScale +
                dragEffect(w.row, w.col).dx,
        width: imageWidth,
        child: GestureDetector(
          onPanUpdate: (dragUpdateDetails) {
            dragUpdate(dragUpdateDetails, w, fitScale);
          },
          onPanEnd: (dragEndDetails) {
            // reset drag state
            setState(() {
              dm = null;
              dragOff = Offset.zero;
            });
          },
          child: w,
        ));
    final p2 = pieces.map(placePiece).toList();
    return Stack(children: p2);
  }

  void dragUpdate(
      DragUpdateDetails dragUpdateDetails, PuzzlePiece w, double fitScale) {
    const thresh = 10; // min pixels to drag to determine direction
    setState(() {
      dragOff += dragUpdateDetails.delta;
      //       print("DO= $dragOff, dm=$dm\n");
      if (dm == null &&
          (dragOff.dx.abs() > thresh || dragOff.dy.abs() > thresh)) {
        final isRow = dragOff.dx.abs() < dragOff.dy.abs();
        dm = _DragMode(isRow: isRow, idx: isRow ? w.row : w.col);
      }
      if (dm != null) {
        if (dm!.isRow) {
          final adjPos =
              (dragOff.dy < 0) ? rowDisp[w.row] - 1 : rowDisp[w.row] + 1;
          if (adjPos < 0 || adjPos >= PuzzleArea.rows) return;
          print(
              'Rows: $rowDisp drag: $dragOff delta: ${widget.pieceSize.height}\n');
          if (widget.pieceSize.height * fitScale < dragOff.dy.abs()) {
            dragOff -= Offset(0, widget.pieceSize.height * fitScale);
            swapEntries(rowDisp, dispRow, w.row, dispRow[adjPos]);
            print('Rows: $rowDisp\n');
          }
        } else {
          final adjPos =
              (dragOff.dx < 0) ? colDisp[w.col] - 1 : colDisp[w.col] + 1;
          if (adjPos < 0 || adjPos > PuzzleArea.cols) return;
          print(
              'Cols: $colDisp drag: $dragOff delta: ${widget.pieceSize.height}\n');
          if (widget.pieceSize.width * fitScale < dragOff.dx.abs()) {
            swapEntries(colDisp, dispCol, w.col, dispCol[adjPos]);
            dragOff -= Offset(widget.pieceSize.width * fitScale, 0);
            print('Cols: $colDisp\n');
          }
        }
      }
    });
  }
}
