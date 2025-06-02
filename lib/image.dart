import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../model/imageobj.dart';
import 'camera_capture.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});
  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true, enableClassification: true),
  );

  ImageObj? image1, image2;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<ImageObj?> _analyze(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;
    FaceLandmark getLM(FaceLandmarkType t) => face.landmarks[t] ?? FaceLandmark(type: t, position: const Point(0, 0));
    FaceContour getCT(FaceContourType t) => face.contours[t] ?? FaceContour(type: t, points: []);

    return ImageObj(
      filePath: file.path,
      title: "Human",
      image: Image(image: XFileImage(file), fit: BoxFit.contain),
      smiling: face.smilingProbability ?? 0.0,
      leftEyeOpenProb: face.leftEyeOpenProbability ?? 0.0,
      rightEyeOpenProb: face.rightEyeOpenProbability ?? 0.0,
      headTurnY: face.headEulerAngleY ?? 0.0,
      headTiltZ: face.headEulerAngleZ ?? 0.0,
      nose: getLM(FaceLandmarkType.noseBase),
      leftEar: getLM(FaceLandmarkType.leftEar),
      rightEar: getLM(FaceLandmarkType.rightEar),
      mouthLeft: getLM(FaceLandmarkType.leftMouth),
      mouthRight: getLM(FaceLandmarkType.rightMouth),
      mouthBottom: getLM(FaceLandmarkType.bottomMouth),
      face: face,
      faceContour: getCT(FaceContourType.face),
      leftEyebrowTop: getCT(FaceContourType.leftEyebrowTop),
      leftEyebrowBottom: getCT(FaceContourType.leftEyebrowBottom),
      rightEyebrowTop: getCT(FaceContourType.rightEyebrowTop),
      rightEyebrowBottom: getCT(FaceContourType.rightEyebrowBottom),
      leftEye: getCT(FaceContourType.leftEye),
      rightEye: getCT(FaceContourType.rightEye),
      upperLipTop: getCT(FaceContourType.upperLipTop),
      upperLipBottom: getCT(FaceContourType.upperLipBottom),
      lowerLipTop: getCT(FaceContourType.lowerLipTop),
      lowerLipBottom: getCT(FaceContourType.lowerLipBottom),
      noseBridge: getCT(FaceContourType.noseBridge),
      noseBottom: getCT(FaceContourType.noseBottom),
    );
  }

  void _showSourceSelect(int imageNum) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(children: [
        ListTile(
          leading: const Icon(Icons.photo),
          title: const Text("갤러리"),
          onTap: () async {
            Navigator.pop(context);
            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (picked != null) {
              final result = await _analyze(picked);
              if (result != null) {
                setState(() {
                  if (imageNum == 1) image1 = result;
                  else image2 = result;
                });
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text("카메라"),
          onTap: () async {
            Navigator.pop(context);
            final file = await Navigator.push<XFile?>(
              context,
              MaterialPageRoute(builder: (_) => const CameraCapturePage()),
            );
            if (file != null) {
              final result = await _analyze(file);
              if (result != null) {
                setState(() {
                  if (imageNum == 1) image1 = result;
                  else image2 = result;
                });
              }
            }
          },
        ),
      ]),
    );
  }

  Widget _buildSlot(String label, ImageObj? img, int num) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showSourceSelect(num),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.grey.shade200,
            ),
            child: img != null ? img.image : const Center(child: Text("Select")),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sync Your Snap")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSlot("Image 1", image1, 1),
          _buildSlot("Image 2", image2, 2),
          ElevatedButton(
            onPressed: image1 != null && image2 != null
                ? () {
                    Navigator.pushNamed(context, '/result', arguments: {
                      'image1': image1,
                      'image2': image2,
                    });
                  }
                : null,
            child: const Text("Compare"),
          ),
        ],
      ),
    );
  }
}