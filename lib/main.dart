import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/PuzzleArea.dart';

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

  void getImage() {
    var image = Image(image: AssetImage('assets/img.jpg'));
    // if (image != null) {
    setState(() {
      _image = image;
    });
    // }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "No Title"),
      ),
      body: SafeArea(
          child: Center(
              child: _image == null
                  ? Text('No image selected.')
                  : FutureBuilder(
                      future: getImageSize(_image!),
                      builder: (context, AsyncSnapshot<Size> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done)
                          return CircularProgressIndicator();
                        return PuzzleArea(_image!, snapshot.data!);
                      }))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        tooltip: 'New Image',
        child: Icon(Icons.add),
      ),
    );
  }
}
