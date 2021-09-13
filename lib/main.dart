import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/PuzzleArea.dart';
import 'package:flutter_puzzle/ImageSelect.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Puzzle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image? _image;

  // we need to find out the image size, to be used in the PuzzlePiece widget
  static Future<ImageInfo> getImageInfo(Image image) async {
    final completer = Completer<ImageInfo>();

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info);
      }),
    );

    return await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final setImage = (Image? i) => () => setState(() => _image = i);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "No Title"),
      ),
      body: SafeArea(
          child: Center(
              child: _image == null
                  ? ImageSelect(setImage: setImage)
                  : FutureBuilder(
                      future: getImageInfo(_image!),
                      builder: (BuildContext context,
                          AsyncSnapshot<ImageInfo> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done)
                          return CircularProgressIndicator();
                        return PuzzleArea(snapshot.data!);
                      }))),
      floatingActionButton: FloatingActionButton(
        onPressed: setImage(null),
        tooltip: 'New Image',
        child: Icon(Icons.add),
      ),
    );
  }
}
