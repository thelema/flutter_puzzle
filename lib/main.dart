import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/PuzzleArea.dart';

import 'package:cached_network_image/cached_network_image.dart';

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
  Map<String, List<Image>> _images = {};
  // final imageDir = Directory('C:\\Users\\ericn\\Downloads');

  _MyHomePageState() {
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
    var alist = _images["Assets"] = [];
    for (final a in ['assets/Giraffe.jfif', 'assets/img.jpg'])
      alist.add(Image.asset(a));
    var blist = _images["Txx"] = [];
    for (int i = 0; i < 37; i++)
      blist.add(Image.asset(
          'assets/txx/t' + (i < 10 ? '0' : '') + i.toString() + '.jpg'));
  }

  // void getImage() {
  //   final i0 = _images.removeLast();
  //   setState(() => _image = i0);
  // }

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
    final setImage = (Image? i) => () => setState(() => _image = i);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "No Title"),
      ),
      body: SafeArea(
          child: Center(
              child: _image == null
                  ? ImageSelect(images: _images, setImage: setImage)
                  : FutureBuilder(
                      future: getImageSize(_image!),
                      builder: (context, AsyncSnapshot<Size> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done)
                          return CircularProgressIndicator();
                        return PuzzleArea(_image!, snapshot.data!);
                      }))),
      floatingActionButton: FloatingActionButton(
        onPressed: setImage(null),
        tooltip: 'New Image',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ImageSelect extends StatelessWidget {
  const ImageSelect({
    Key? key,
    required Map<String, List<Image>> images,
    required this.setImage,
  })  : _images = images,
        super(key: key);

  final Map<String, List<Image>> _images;
  final void Function() Function(Image? i) setImage;

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: _images.entries
            .expand((e) => [
                  Text(e.key),
                  Wrap(
                      children: e.value
                          .map((i) => SizedBox(
                              width: 300,
                              child: MaterialButton(
                                  onPressed: setImage(i), child: i)))
                          .toList())
                ])
            .toList());
  }
}
