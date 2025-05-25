import 'package:cross_file_image/cross_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class ImageObj{
  final String title;
  final Image image;
  ImageObj({
    required this.title,
    required this.image,
  });
}

class _ImagePageState extends State<ImagePage> {
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  List<ImageObj> images = [];
  Future<void> _doDectect() async {
    final picker = ImagePicker();
    List<XFile> imagesFromPicker = await picker.pickMultiImage();
    List<int> faceCount = [];
    images = [];
    for(XFile item in imagesFromPicker){
      final faces = await _faceDetector.processImage(InputImage.fromFilePath(item.path));
      faceCount.add(faces.length);
    }
    setState(() {
      int i=0;
      for(XFile item in imagesFromPicker){
        images.add(
          ImageObj(
            title: faceCount[i++] > 0 ? "Human":"No Human", image: Image(image: XFileImage(item))
            )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: images.length > 0 ? ListView.builder(
            itemBuilder: (context, index){
              return ListTile(
                leading: images[index].image,
                title: Text(images[index].title),
                onTap: (){

                },
              );
            }) : Text("No Images"),
          ),
           floatingActionButton: FloatingActionButton(
            onPressed: _doDectect,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), 
    );
  }
}
