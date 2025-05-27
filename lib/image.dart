import 'dart:math';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'model/imageobj.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
    ),
  );
  
  ImageObj? image1,image2;

  Future<ImageObj?> _detectImage() async {
    final picker = ImagePicker();
    final imagesFromPicker = await picker.pickMultiImage();

    if (imagesFromPicker.isNotEmpty) {
      final XFile item = imagesFromPicker.first;
      final inputImage = InputImage.fromFilePath(item.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      final hasHuman = faces.isNotEmpty;
      final smiling = hasHuman ? (faces.first.smilingProbability ?? 0.0) : 0.0;
      final leftEyeOpenProbability = hasHuman ? (faces.first.leftEyeOpenProbability ?? 0.0) : 0.0;
      final rightEyeOpenProbability = hasHuman ? (faces.first.rightEyeOpenProbability ?? 0.0) : 0.0;
      final headEulerAngleY = hasHuman ? (faces.first.headEulerAngleY ?? 0.0) : 0.0;
      final headEulerAngleZ = hasHuman ? (faces.first.headEulerAngleZ ?? 0.0) : 0.0; 
      final nose = hasHuman ? faces.first.landmarks[FaceLandmarkType.noseBase] : null;
      final leftEar = hasHuman ? faces.first.landmarks[FaceLandmarkType.leftEar] : null;
      final rightEar = hasHuman ? faces.first.landmarks[FaceLandmarkType.rightEar] : null;
      final mouthLeft = hasHuman ? faces.first.landmarks[FaceLandmarkType.leftMouth] : null;
      final mouthRight = hasHuman ? faces.first.landmarks[FaceLandmarkType.rightMouth] : null;
      final mouthBottom = hasHuman ? faces.first.landmarks[FaceLandmarkType.bottomMouth] : null;
      return ImageObj(
        title: hasHuman ? "Human" : "No Human",
        image: Container(
          constraints: const BoxConstraints.expand(),
          child: Image(
            image: XFileImage(item),
            fit: BoxFit.cover,
          ),
        ),
        smiling: smiling,
        leftEyeOpenProb: leftEyeOpenProbability,
        rightEyeOpenProb: rightEyeOpenProbability,
        headTurnY: headEulerAngleY, 
        headTiltZ: headEulerAngleZ,
        nose: nose!,
        leftEar: leftEar!,
        rightEar: rightEar!,
        mouthLeft: mouthLeft!,
        mouthRight: mouthRight!,
        mouthBottom: mouthBottom!,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: const Text('Sync Your Snap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await _detectImage();
                if(!mounted) return;
                if (result != null) {
                  if (result.title == "No Human") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No face detected. Please select another image.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    setState(() {
                      image1 = result;
                    });
                  }
                }
              },
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: image1 != null
                    ? image1!.image
                    : const Center(
                        child: Text(
                          "Tap to select Image 1",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
            ),
          ),

          const Divider(height: 1, color: Colors.black),

          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await _detectImage();
                if(!mounted) return;
                if (result != null) {
                  if (result.title == "No Human") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No face detected. Please select another image.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    setState(() {
                      image2 = result;
                    });
                  }
                }
                
              },
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade300,
                child: image2 != null
                    ? image2!.image
                    : const Center(
                        child: Text(
                          "Tap to select Image 2",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (image1 != null && image2 != null)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/result', arguments: {'image1':image1, 'image2':image2});
              },
              icon: const Icon(Icons.compare),
              label: const Text('Compare'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}