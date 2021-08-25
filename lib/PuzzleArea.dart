import 'dart:async';

import 'PuzzlePiece.dart';

import 'package:flutter/material.dart';

class PuzzleArea extends StatefulWidget {
  static const int rows = 3;
  static const int cols = 3;
  final Image image;

  PuzzleArea(this.image);

  // we need to find out the image size, to be used in the PuzzlePiece widget
  static Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;

    return imageSize;
  }

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  static Future<List<PuzzlePiece>> splitImage(Image image) async {
    Size imageSize = await getImageSize(image);
    List<PuzzlePiece> pieces = [];
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        pieces.add(PuzzlePiece(
            key: GlobalKey(),
            image: image,
            imageSize: imageSize,
            row: x,
            col: y,
            maxRow: rows,
            maxCol: cols));
      }
    }
    return pieces;
  }

  @override
  _MyPuzzleAreaState createState() => _MyPuzzleAreaState(image);
}

class _MyPuzzleAreaState extends State<PuzzleArea> {
  List rowPerm = List.generate(PuzzleArea.rows, (i) => i);
  List colPerm = List.generate(PuzzleArea.cols, (i) => i);
  List<PuzzlePiece> pieces = [];

  _MyPuzzleAreaState(Image image);

  @override
  build(BuildContext context) {
    return FutureBuilder(
        future: PuzzleArea.splitImage(widget.image),
        builder: (context, snapshot) => !snapshot.hasData
            ? CircularProgressIndicator()
            : Stack(
                children: pieces
                    .map((PuzzlePiece w) => Positioned(
                        top: rowPerm[w.row] * 50,
                        left: colPerm[w.col] * 50,
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
                        )))
                    .toList()));
  }
}
