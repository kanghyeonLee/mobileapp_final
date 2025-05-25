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

class ImageObj {
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
    final List<XFile> imagesFromPicker = await picker.pickMultiImage();
    final List<ImageObj> tempList = [];

    for (XFile item in imagesFromPicker) {
      final inputImage = InputImage.fromFilePath(item.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      final hasHuman = faces.isNotEmpty;

      tempList.add(
        ImageObj(
          title: hasHuman ? "Human" : "No Human",
          image: Image(image: XFileImage(item), width: 64, height: 64, fit: BoxFit.cover),
        ),
      );
    }

    setState(() {
      images.addAll(tempList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Detection Gallery"),
      ),
      body: SafeArea(
        child: images.isNotEmpty
            ? ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: images[index].image,
                    title: Text(images[index].title),
                    onTap: () {
                      // 추가 동작 가능
                    },
                  );
                },
              )
            : const Center(
                child: Text("No Images Selected"),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _doDectect,
        tooltip: 'Select Images',
        child: const Icon(Icons.add),
      ),
    );
  }
}