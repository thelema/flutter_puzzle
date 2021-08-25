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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "No Title"),
      ),
      body: SafeArea(
          child: new Center(
        child: _image == null
            ? new Text('No image selected.')
            : new PuzzleArea(_image!),
      )),
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
