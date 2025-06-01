import 'dart:math';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
    ),
  );

  ImageObj? image1, image2;
  final TextEditingController _descriptionController = TextEditingController();

  Future<ImageObj?> _detectImage() async {
    final picker = ImagePicker();
    final imagesFromPicker = await picker.pickMultiImage();

    if (imagesFromPicker.isNotEmpty) {
      final XFile item = imagesFromPicker.first;
      final inputImage = InputImage.fromFilePath(item.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      final hasHuman = faces.isNotEmpty;

      final Face face = faces.first;

      // 랜드마크 추출
      final nose = hasHuman ? face.landmarks[FaceLandmarkType.noseBase] : null;
      final leftEar =
          hasHuman ? face.landmarks[FaceLandmarkType.leftEar] : null;
      final rightEar =
          hasHuman ? face.landmarks[FaceLandmarkType.rightEar] : null;
      final mouthLeft =
          hasHuman ? face.landmarks[FaceLandmarkType.leftMouth] : null;
      final mouthRight =
          hasHuman ? face.landmarks[FaceLandmarkType.rightMouth] : null;
      final mouthBottom =
          hasHuman ? face.landmarks[FaceLandmarkType.bottomMouth] : null;

      // 컨투어 추출
      FaceContour getContour(FaceContourType type) =>
          face.contours[type] ?? FaceContour(type: type, points: []);

      final faceContour = getContour(FaceContourType.face);
      final leftEyebrowTop = getContour(FaceContourType.leftEyebrowTop);
      final leftEyebrowBottom = getContour(FaceContourType.leftEyebrowBottom);
      final rightEyebrowTop = getContour(FaceContourType.rightEyebrowTop);
      final rightEyebrowBottom = getContour(FaceContourType.rightEyebrowBottom);
      final leftEyeContour = getContour(FaceContourType.leftEye);
      final rightEyeContour = getContour(FaceContourType.rightEye);
      final upperLipTop = getContour(FaceContourType.upperLipTop);
      final upperLipBottom = getContour(FaceContourType.upperLipBottom);
      final lowerLipTop = getContour(FaceContourType.lowerLipTop);
      final lowerLipBottom = getContour(FaceContourType.lowerLipBottom);
      final noseBridge = getContour(FaceContourType.noseBridge);
      final noseBottom = getContour(FaceContourType.noseBottom);

      // 표정 및 방향
      final smiling = hasHuman ? (face.smilingProbability ?? 0.0) : 0.0;
      final leftEyeOpenProbability =
          hasHuman ? (face.leftEyeOpenProbability ?? 0.0) : 0.0;
      final rightEyeOpenProbability =
          hasHuman ? (face.rightEyeOpenProbability ?? 0.0) : 0.0;
      final headEulerAngleY = hasHuman ? (face.headEulerAngleY ?? 0.0) : 0.0;
      final headEulerAngleZ = hasHuman ? (face.headEulerAngleZ ?? 0.0) : 0.0;

      // ImageObj 생성
      return ImageObj(
        title: hasHuman ? "Human" : "No Human",
        image: Container(
          constraints: const BoxConstraints.expand(),
          child: Image(image: XFileImage(item), fit: BoxFit.contain),
        ),
        smiling: smiling,
        leftEyeOpenProb: leftEyeOpenProbability,
        rightEyeOpenProb: rightEyeOpenProbability,
        headTurnY: headEulerAngleY,
        headTiltZ: headEulerAngleZ,
        nose:
            nose ??
            FaceLandmark(
              type: FaceLandmarkType.noseBase,
              position: const Point(0, 0),
            ),
        leftEar:
            leftEar ??
            FaceLandmark(
              type: FaceLandmarkType.leftEar,
              position: const Point(0, 0),
            ),
        rightEar:
            rightEar ??
            FaceLandmark(
              type: FaceLandmarkType.rightEar,
              position: const Point(0, 0),
            ),
        mouthLeft:
            mouthLeft ??
            FaceLandmark(
              type: FaceLandmarkType.leftMouth,
              position: const Point(0, 0),
            ),
        mouthRight:
            mouthRight ??
            FaceLandmark(
              type: FaceLandmarkType.rightMouth,
              position: const Point(0, 0),
            ),
        mouthBottom:
            mouthBottom ??
            FaceLandmark(
              type: FaceLandmarkType.bottomMouth,
              position: const Point(0, 0),
            ),
        face: face,
        faceContour: faceContour,
        leftEyebrowTop: leftEyebrowTop,
        leftEyebrowBottom: leftEyebrowBottom,
        rightEyebrowTop: rightEyebrowTop,
        rightEyebrowBottom: rightEyebrowBottom,
        leftEye: leftEyeContour,
        rightEye: rightEyeContour,
        upperLipTop: upperLipTop,
        upperLipBottom: upperLipBottom,
        lowerLipTop: lowerLipTop,
        lowerLipBottom: lowerLipBottom,
        noseBridge: noseBridge,
        noseBottom: noseBottom,
      );
    }
    return null;
  }

  void _handleCompare() {
    if (image1 != null && image2 != null) {
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {'image1': image1, 'image2': image2},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지 2장을 모두 선택해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Your Snap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        actions: [IconButton(icon: const Icon(Icons.person), onPressed: () {})],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 버튼 공간 확보
            children: [
              const Text(
                "사진을 선택한 후 Compare 버튼을 눌러 두 얼굴의 표정을 비교하세요.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final result = await _detectImage();
                  if (!mounted) return;
                  if (result != null) {
                    if (result.title == "No Human") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('얼굴이 감지되지 않았습니다. 다른 이미지를 선택하세요.'),
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
                  height: 200,
                  color: Colors.grey.shade200,
                  child:
                      image1 != null
                          ? image1!.image
                          : const Center(
                            child: Text(
                              "Tap to select Image 1",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final result = await _detectImage();
                  if (!mounted) return;
                  if (result != null) {
                    if (result.title == "No Human") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('얼굴이 감지되지 않았습니다. 다른 이미지를 선택하세요.'),
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
                  height: 200,
                  color: Colors.grey.shade300,
                  child:
                      image2 != null
                          ? image2!.image
                          : const Center(
                            child: Text(
                              "Tap to select Image 2",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                ),
              ),
            ],
          ),

          // 고정 Compare 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _handleCompare,
                icon: const Icon(Icons.compare),
                label: const Text('Compare'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
