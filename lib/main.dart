import 'dart:async';
import 'dart:io';
import 'dart:math';

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
  List<Image> _images = [];
  // final imageDir = Directory('C:\\Users\\ericn\\Downloads');

  void getImage() {
    if (_images.isEmpty) {
      for (final a in ['assets/Giraffe.jfif', 'assets/img.jpg'])
        _images.add(Image.asset(a));
      // TODO: get images from other sources
      // final images = imageDir.listSync().expand((FileSystemEntity e) {
      //   if (!(e is File)) return [];
      //   if (p.extension(e.path) != '.jpg') return [];
      //   return [e];
      // }).toList();
      // final image = Image.file(images[Random().nextInt(images.length)]);
//      final image = Image(image: AssetImage('assets/img.jpg'));
      // final image = Image.network(
      //     'https://images.unsplash.com/photo-1547721064-da6cfb341d50');
      // "https://www.kindacode.com/wp-content/uploads/2021/04/1.png");
    }
    assert(_images.isNotEmpty);
    final i0 = _images.removeLast();
    setState(() => _image = i0);
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

    return await completer.future;
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
        onPressed: () => getImage(),
        tooltip: 'New Image',
        child: Icon(Icons.add),
      ),
    );
  }
}
