import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageWidget extends StatefulWidget {
  ImageWidget({Key key, this.imgUrl}) : super(key : key);

  final String imgUrl;

  createState() => ImageWidgetState();
}

class ImageWidgetState extends State<ImageWidget> with AutomaticKeepAliveClientMixin {
  
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
    super.build(context);
    return _loading ? Center(child: SpinKitChasingDots(color: Colors.blue,)) :
    Image.memory(
      _img,
    );
  }
  
  bool get wantKeepAlive => true;
}