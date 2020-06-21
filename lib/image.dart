import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class ImageWidget extends StatefulWidget {
  ImageWidget({Key key, this.imgUrl}) : super(key : key);

  final String imgUrl;

  createState() => ImageWidgetState();
}

class ImageWidgetState extends State<ImageWidget> {
  
  bool _loading = true;
  Uint8List _img;

  getImage() async {
    var imgRef = await FirebaseStorage.instance.getReferenceFromUrl('gs://yehchina-mobile-app.appspot.com/' + widget.imgUrl);
    var imgData = await imgRef.getData(1024 * 64);
    if(mounted) {
      setState(() {
        _img = imgData;
        _loading = false;
      });
    }
  }
  initState() {
    super.initState();
    _loading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getImage();
    });
  }

  build(context) {
    return _loading ? Text('loading') :
    Image.memory(
      _img,
      height: 200
    );
  }
}