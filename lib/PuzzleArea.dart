import 'dart:math';

import 'PuzzlePiece.dart';

import 'package:flutter/material.dart';

class PuzzleArea extends StatefulWidget {
  static const int rows = 8;
  static const int cols = 8;
  final ImageInfo image;
  final Size drawPieceSize;

  PuzzleArea(this.image) : drawPieceSize = Size(800 / cols, 800 / rows);

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  static List<PuzzlePiece> splitImage(
      ImageInfo image, Size pieceSize, Size drawPieceSize) {
    List<PuzzlePiece> pieces = [];
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        final rect =
            Offset(pieceSize.width * x, pieceSize.height * y) & pieceSize;
        pieces.add(PuzzlePiece(
            image: image, rect: rect, drawSize: drawPieceSize, col: x, row: y));
      }
    }
    return pieces;
  }

  @override
  _MyPuzzleAreaState createState() => _MyPuzzleAreaState(
      pieces: splitImage(
          image,
          Size(image.image.width / cols, image.image.height / rows),
          drawPieceSize));
}

class _DragMode {
  bool isRow; //! whether we're dragging rows or columnns
  List<int> idx; //! the row/columns we're dragging
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
  Random _rand = Random();

  _MyPuzzleAreaState({required this.pieces})
      : rowDisp = List.generate(PuzzleArea.rows, (i) => i),
        colDisp = List.generate(PuzzleArea.cols, (i) => i),
        dispRow = List.generate(PuzzleArea.rows, (i) => i),
        dispCol = List.generate(PuzzleArea.cols, (i) => i) {
    _shuffle();
  }

  Offset dragEffect(int r, int c) {
    final ldm = dm;
    if (ldm == null) return Offset.zero;
    if (ldm.isRow) {
      if (!ldm.idx.contains(r)) return Offset.zero;
      return Offset(0, dragOff.dy);
    } else {
      if (!ldm.idx.contains(c)) return Offset.zero;
      return Offset(dragOff.dx, 0);
    }
  }

  @override
  build(BuildContext context) {
    // final Size contextSize = MediaQuery.of(context).size;
    // final Size imageSize = Size(widget.image.image.width.toDouble(),
    //     widget.image.image.height.toDouble());
    //min<double>(contextSize.width / imageSize.width,
    // contextSize.height / imageSize.height);
    // final imageHeight = contextSize.height * fitScale;
    final pieceWidth = widget.drawPieceSize.width;
    final pieceHeight = widget.drawPieceSize.height;
    final placePiece = (PuzzlePiece w) => Positioned(
        top: (rowDisp[w.row] * pieceHeight) + dragEffect(w.row, w.col).dy,
        left: (colDisp[w.col] * pieceWidth) + dragEffect(w.row, w.col).dx,
        width: pieceWidth,
        height: pieceHeight,
        child: GestureDetector(
          onPanUpdate: (dragUpdateDetails) {
            _dragUpdate(dragUpdateDetails, w);
          },
          onPanEnd: (dragEndDetails) {
            // reset drag state
            setState(() {
              dm = null;
              dragOff = Offset.zero;
              _checkDone();
            });
          },
          child: w,
        ));
    final p2 = pieces.map(placePiece).toList();
    return Stack(children: p2);
  }

  bool _isDone() {
    for (int x = 0; x < PuzzleArea.cols; x++) if (dispRow[x] != x) return false;
    for (int y = 0; y < PuzzleArea.rows; y++) if (dispCol[y] != y) return false;
    return true;
  }

  void _shuffle() {
    rowDisp.shuffle(_rand);
    colDisp.shuffle(_rand);
    // fix up inverse lookup tables
    for (int x = 0; x < PuzzleArea.cols; x++) dispRow[rowDisp[x]] = x;
    for (int y = 0; y < PuzzleArea.rows; y++) dispCol[colDisp[y]] = y;
  }

  void _checkDone() {
    if (_isDone()) _shuffle();
  }

  void _dragUpdate(DragUpdateDetails dragUpdateDetails, PuzzlePiece w) {
    const thresh = 10; // min pixels to drag to determine direction
    setState(() {
      dragOff += dragUpdateDetails.delta;
      //       print("DO= $dragOff, dm=$dm\n");
      if (dm == null &&
          (dragOff.dx.abs() > thresh || dragOff.dy.abs() > thresh)) {
        final isRow = dragOff.dx.abs() < dragOff.dy.abs();
        dm = _DragMode(
            isRow: isRow,
            idx: isRow
                ? _getCluster(w.row, rowDisp)
                : _getCluster(w.col, colDisp));
      }
      if (dm != null) {
        if (dm!.isRow) {
          final adjPos = rowDisp[w.row] + dragOff.dy.sign.toInt();
          if (adjPos < 0 || adjPos >= PuzzleArea.rows) return;
          if (widget.drawPieceSize.height < dragOff.dy.abs()) {
            rotatePos(rowDisp, dispRow, dm!.idx, dragOff.dy.sign.toInt());
            dragOff -= Offset(0, widget.drawPieceSize.height * dragOff.dy.sign);
          }
        } else {
          final adjPos = colDisp[w.col] + dragOff.dx.sign.toInt();
          if (adjPos < 0 || adjPos > PuzzleArea.cols) return;
          if (widget.drawPieceSize.width < dragOff.dx.abs()) {
            rotatePos(colDisp, dispCol, dm!.idx, dragOff.dx.sign.toInt());
            dragOff -= Offset(widget.drawPieceSize.width * dragOff.dx.sign, 0);
          }
        }
      }
    });
  }

  List<int> _getCluster(int idx, List<int> idxDisp) {
    List<int> ret = [idx];
    for (int i = idx - 1; i >= 0; i--) {
      if (idxDisp[i] - idxDisp[idx] != i - idx) break;
      ret.insert(0, i);
    }
    for (int i = idx + 1; i < idxDisp.length; i++) {
      if (idxDisp[i] - idxDisp[idx] != i - idx) break;
      ret.add(i);
    }

    return ret;
  }

  static void rotatePos(
      List<int> idxDisp, List<int> dispIdx, List<int> idx, int dir) {
    assert(idx.isNotEmpty);
    assert(dir.abs() == 1); // must be 1 or -1
    print('Rotate $idxDisp, $dispIdx, $idx, $dir');
    try {
      if (dir == 1) {
        // moving down; move item from below idxes to above them
        // A I0..If temp B => A temp I0..If B
        final temp = dispIdx[idxDisp[idx.last] + 1];
        idxDisp[temp] -= idx.length;
        for (int i in idx) idxDisp[i]++;
        // fix dispIdx
        for (int i in [temp, ...idx]) dispIdx[idxDisp[i]] = i;
      } else {
        // moving up; move item from above idxes to below them
        // A temp I0..If B => A I0..If temp B
        final temp = dispIdx[idxDisp[idx.first] - 1];
        idxDisp[temp] += idx.length;
        for (int i in idx) idxDisp[i]--;
        // fix dispIdx
        for (int i in [temp, ...idx]) dispIdx[idxDisp[i]] = i;
      }
      print('is $idxDisp, $dispIdx');
    } catch (e) {
      print('Failed $e');
    }
  }
}
