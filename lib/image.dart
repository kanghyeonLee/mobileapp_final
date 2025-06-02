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
      face.landmarks[type] ?? FaceLandmark(type: type, position: const Point(0, 0));

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
  _cameraController = CameraController(cameraDescription, ResolutionPreset.medium);
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

  // Updated Flutter UI with:
// 1. Dual image selection (Image1 & Image2)
// 2. Option bottom sheet to pick from Camera or Gallery
// 3. Display both selected images before comparison

// Replace your current `build` method with this adjusted structure
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
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Step 1: Image 1 선택"),
        const SizedBox(height: 8),
        _buildImageSelectionWidget(1),
        const SizedBox(height: 24),
        const Text("Step 2: Image 2 선택"),
        const SizedBox(height: 8),
        _buildImageSelectionWidget(2),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: image1 != null && image2 != null
              ? () {
                  Navigator.pushNamed(context, '/result', arguments: {
                    'image1': image1,
                    'image2': image2,
                  });
                }
              : null,
          child: const Text("Compare Faces"),
        ),
        const SizedBox(height: 12),
        if (image1 != null) image1!.image,
        const SizedBox(height: 12),
        if (image2 != null) image2!.image,
      ],
    ),
  );
}

Widget _buildImageSelectionWidget(int imageNumber) {
  return GestureDetector(
    onTap: () => _showImageSourceOptions(imageNumber),
    child: Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          imageNumber == 1
              ? (image1 == null ? "Select Image 1" : "Reselect Image 1")
              : (image2 == null ? "Select Image 2" : "Reselect Image 2"),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}

void _showImageSourceOptions(int imageNumber) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await _detectImage();
                if (!mounted || result == null) return;
                setState(() {
                  if (imageNumber == 1) {
                    image1 = result;
                  } else {
                    image2 = result;
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                await _initializeCamera(_cameras[_selectedCameraIndex]);
                await _initializeCameraControllerFuture;
                final XFile photo = await _cameraController.takePicture();
                final inputImage = InputImage.fromFilePath(photo.path);
                final faces = await _faceDetector.processImage(inputImage);
                if (faces.isNotEmpty) {
                  final result = await _analyzeImage(photo, faces.first);
                  if (!mounted) return;
                  setState(() {
                    if (imageNumber == 1) {
                      image1 = result;
                    } else {
                      image2 = result;
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("얼굴이 감지되지 않았습니다.")),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
}