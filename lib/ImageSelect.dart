//import 'dart:html';
//import 'dart:typed_data' show Uint8List;

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
    final body = () async {
      try {
        Uri u = Uri.parse(s);
        // fetch URL and scrape it for images
        var resp = await http.get(u);
        return resp.body;
      } catch (_) {
        return s;
      }
    }();
    var exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    var exp2 = RegExp(r'jpg|png|jpeg');
    List<Image> ret = [];
    for (var match in exp.allMatches(await body)) {
      var ss = s.substring(match.start, match.end);
      print('found URL: ss\n');
      if (exp2.hasMatch(ss)) ret.add(Image.network(ss));
    }

    return ret;
  }

  Image? getTxxImage(int i) {
    final fn = 'txx/t' + (i < 10 ? '0' : '') + i.toString() + '.jpg';
    return Image.asset(fn);
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
          for (final a in ['assets/Giraffe.jfif', 'assets/img.jpg'])
            img(Image.asset(a)),
        ],
      ),
      Text('Txx'),
      Wrap(children: [
        for (int i = 1; i < 37; i++)
          if (getTxxImage(i) != null) img(getTxxImage(i)!),
      ]),
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
