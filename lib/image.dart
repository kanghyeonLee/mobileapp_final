import 'dart:math';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'model/imageobj.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<ImageObj> _analyzeImage(XFile file, Face face) async {
    FaceLandmark? getLandmark(FaceLandmarkType type) =>
        face.landmarks[type] ??
        FaceLandmark(type: type, position: const Point(0, 0));

    FaceContour getContour(FaceContourType type) =>
        face.contours[type] ?? FaceContour(type: type, points: []);

    return ImageObj(
      filePath: file.path,
      title: "Human",
      image: Container(
        constraints: const BoxConstraints.expand(),
        child: Image(image: XFileImage(file), fit: BoxFit.contain),
      ),
      smiling: face.smilingProbability ?? 0.0,
      leftEyeOpenProb: face.leftEyeOpenProbability ?? 0.0,
      rightEyeOpenProb: face.rightEyeOpenProbability ?? 0.0,
      headTurnY: face.headEulerAngleY ?? 0.0,
      headTiltZ: face.headEulerAngleZ ?? 0.0,
      nose: getLandmark(FaceLandmarkType.noseBase)!,
      leftEar: getLandmark(FaceLandmarkType.leftEar)!,
      rightEar: getLandmark(FaceLandmarkType.rightEar)!,
      mouthLeft: getLandmark(FaceLandmarkType.leftMouth)!,
      mouthRight: getLandmark(FaceLandmarkType.rightMouth)!,
      mouthBottom: getLandmark(FaceLandmarkType.bottomMouth)!,
      face: face,
      faceContour: getContour(FaceContourType.face),
      leftEyebrowTop: getContour(FaceContourType.leftEyebrowTop),
      leftEyebrowBottom: getContour(FaceContourType.leftEyebrowBottom),
      rightEyebrowTop: getContour(FaceContourType.rightEyebrowTop),
      rightEyebrowBottom: getContour(FaceContourType.rightEyebrowBottom),
      leftEye: getContour(FaceContourType.leftEye),
      rightEye: getContour(FaceContourType.rightEye),
      upperLipTop: getContour(FaceContourType.upperLipTop),
      upperLipBottom: getContour(FaceContourType.upperLipBottom),
      lowerLipTop: getContour(FaceContourType.lowerLipTop),
      lowerLipBottom: getContour(FaceContourType.lowerLipBottom),
      noseBridge: getContour(FaceContourType.noseBridge),
      noseBottom: getContour(FaceContourType.noseBottom),
    );
  }

  Future<void> _setupCameras() async {
    _cameras = await availableCameras();
    _selectedCameraIndex = _cameras.indexWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );
    if (_selectedCameraIndex == -1) _selectedCameraIndex = 0; // fallback
    await _initializeCamera(_cameras[_selectedCameraIndex]);
  }

  void _toggleCamera() async {
    if (_cameras.isEmpty) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );
    _initializeCameraControllerFuture = _cameraController.initialize();
    setState(() {});
  }

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

      final smiling = hasHuman ? (face.smilingProbability ?? 0.0) : 0.0;
      final leftEyeOpenProbability =
          hasHuman ? (face.leftEyeOpenProbability ?? 0.0) : 0.0;
      final rightEyeOpenProbability =
          hasHuman ? (face.rightEyeOpenProbability ?? 0.0) : 0.0;
      final headEulerAngleY = hasHuman ? (face.headEulerAngleY ?? 0.0) : 0.0;
      final headEulerAngleZ = hasHuman ? (face.headEulerAngleZ ?? 0.0) : 0.0;

      return ImageObj(
        filePath: item.path,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body:
          image1 == null
              ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Step 1: 갤러리에서 이미지 1을 선택하세요.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final result = await _detectImage();
                      if (!mounted) return;
                      if (result != null && result.title == "Human") {
                        setState(() {
                          image1 = result;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("얼굴이 감지되지 않았습니다.")),
                        );
                      }
                    },
                    child: Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Text(
                          "Tap to select Image 1",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Stack(
                children: [
                  FutureBuilder(
                    future: _initializeCameraControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_cameraController);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),

                  if (image1 != null)
                    Opacity(
                      opacity: 0.3,
                      child: SizedBox.expand(child: image1!.image),
                    ),

                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(
                        "Image 1을 참고해서 표정을 맞춰보세요!",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _initializeCameraControllerFuture;
                            final XFile photo =
                                await _cameraController.takePicture();
                            final inputImage = InputImage.fromFilePath(
                              photo.path,
                            );
                            final faces = await _faceDetector.processImage(
                              inputImage,
                            );
                            if (faces.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("얼굴이 감지되지 않았습니다."),
                                ),
                              );
                              return;
                            }
                            final result = await _analyzeImage(
                              photo,
                              faces.first,
                            );
                            setState(() {
                              image2 = result;
                            });

                            Navigator.pushNamed(
                              context,
                              '/result',
                              arguments: {'image1': image1, 'image2': image2},
                            );
                          } catch (e) {
                            debugPrint("Camera error: $e");
                          }
                        },
                        icon: const Icon(Icons.camera),
                        label: const Text('Take Image 2 & Compare'),
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
