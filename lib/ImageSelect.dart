import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageSelect extends StatefulWidget {
  const ImageSelect({
    Key? key,
    required this.setImage,
  }) : super(key: key);

  final void Function() Function(Image? i) setImage;

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect> {
  List<Image> webImg = [];
  Image? pasteImage;

  _ImageSelectState() {
    // TODO: get images from other sources
    // final imageDir = Directory('C:\\Users\\ericn\\Downloads');

    // final images = imageDir.listSync().expand((FileSystemEntity e) {
    //   if (!(e is File)) return [];
    //   if (p.extension(e.path) != '.jpg') return [];
    //   return [e];
    // }).toList();
    // final image = Image.file(images[Random().nextInt(images.length)]);
//      final image = Image(image: AssetImage('assets/img.jpg'));
    // final image = Image.network(
    //     'https://images.unsplash.com/photo-1547721064-da6cfb341d50');
    // // "https://www.kindacode.com/wp-content/uploads/2021/04/1.png");
    // var nlist = _images["Network"] = [];
    // nlist.add(image);
  }

  static Future<List<Image>> scrape(String s) async {
    final exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    final exp2 = RegExp(r'jpg|png|jpeg');
    if (exp2.hasMatch(s)) return [Image.network(s)];

    final u = Uri.parse(s);
    var resp = await http.get(u);
    List<Image> ret = [];
    for (var match in exp.allMatches(resp.body)) {
      var ss = resp.body.substring(match.start, match.end);
      print('found URL: $ss\n');
      if (exp2.hasMatch(ss)) ret.add(Image.network(ss));
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    // document.onPaste.listen((ClipboardEvent e) {
    //   DataTransferItemList? items = e.clipboardData?.items;
    //   if (items != null && items.length != null) {
    //     for (int i = 0; i < items.length!; i++) {
    //       var blob = items[i].getAsFile();
    //       if (blob != null) {
    //         setState(() => pasteImage =
    //             Image.memory(Uint8List.fromList(blob.toString().codeUnits)));
    //         break;
    //       }
    //     }
    //   }
    // });
    final img = (Image i) => SizedBox(
        width: 300,
        child: MaterialButton(onPressed: widget.setImage(i), child: i));
    final imgf = (String fn) => img(Image.file(File(fn)));
    return ListView(scrollDirection: Axis.vertical, children: [
      if (pasteImage != null) ...[Text('Pasted'), img(pasteImage!)],
      Text('FromWeb'),
      TextField(
        onSubmitted: (String s) =>
            scrape(s).then((value) => setState(() => webImg = value)),
      ),
      Wrap(children: [
        for (final i in webImg) img(i),
      ]),
      Text('Assets'),
      Wrap(
        children: [
          for (final a in ['assets/Giraffe.jfif', 'assets/img.jpg']) imgf(a),
        ],
      ),
      Text('Txx'),
      Wrap(
          children: Directory('assets/txx')
              .listSync(recursive: true)
              .where((e) => e.path.endsWith('.jpg'))
              .map((e) => imgf(e.path))
              .toList()),
    ]);
    // _images.entries
    //     .expand((e) => [
    //           Text(e.key),
    //           Wrap(
    //               children: e.value
    //                   .map((i) => SizedBox(
    //                       width: 300,
    //                       child: MaterialButton(
    //                           onPressed: widget.setImage(i), child: i)))
    //                   .toList())
    //         ])
    //     .toList());
  }
}
