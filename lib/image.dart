import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../model/imageobj.dart';
import 'camera_capture.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});
  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  ImageObj? image1, image2;
  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String && image1 == null) {
      // args는 'assets/image1.png' 같은 경로
      _loadAssetImage(args).then((file) async {
        final result = await _analyze(XFile(file.path));
        if (result != null) {
          setState(() {
            image1 = result;
          });
        }
      });
    }
  }

  /// Copies asset image to a temporary file and returns it.
  Future<File> _loadAssetImage(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<ImageObj?> _analyze(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;
    FaceLandmark getLM(FaceLandmarkType t) =>
        face.landmarks[t] ?? FaceLandmark(type: t, position: const Point(0, 0));
    FaceContour getCT(FaceContourType t) =>
        face.contours[t] ?? FaceContour(type: t, points: []);

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("이미지 선택"),
        content: const Text("어디서 이미지를 가져올까요?"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo),
            label: const Text("갤러리"),
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                final result = await _analyze(picked);
                if (result != null) {
                  setState(() {
                    if (imageNum == 1)
                      image1 = result;
                    else
                      image2 = result;
                  });
                }
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("카메라"),
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기
              final file = await Navigator.push<XFile?>(
                context,
                MaterialPageRoute(
                  builder: (_) => const CameraCapturePage(),
                ),
              );
              if (file != null) {
                final result = await _analyze(file);
                if (result != null) {
                  setState(() {
                    if (imageNum == 1)
                      image1 = result;
                    else
                      image2 = result;
                  });
                }
              }
            },
          ),
        ],
      ),
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
            child:
                img != null ? img.image : const Center(child: Text("Select")),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Your Snap')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 166, 218, 244),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Practice'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('List'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/list');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSlot("따라할 이미지", image1, 1),
          _buildSlot("나의 이미지", image2, 2),
          ElevatedButton(
            onPressed:
                image1 != null && image2 != null
                    ? () {
                      Navigator.pushNamed(
                        context,
                        '/result',
                        arguments: {'image1': image1, 'image2': image2},
                      );
                    }
                    : null,
            child: const Text("비교하기"),
          ),
        ],
      ),
    );
  }
}
