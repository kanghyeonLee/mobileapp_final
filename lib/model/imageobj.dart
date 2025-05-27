import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

ImageObj? selectedImage1;
ImageObj? selectedImage2;

class ImageObj {
  final String title;
  final Widget image;
  final double smiling;
  final double leftEyeOpenProb;
  final double rightEyeOpenProb;
  final double headTurnY;
  final double headTiltZ;
  final FaceLandmark nose;
  final FaceLandmark leftEar;
  final FaceLandmark rightEar;
  final FaceLandmark mouthLeft;
  final FaceLandmark mouthRight;
  final FaceLandmark mouthBottom;
  ImageObj({
    required this.title,
    required this.image,
    required this.smiling,
    required this.leftEyeOpenProb,
    required this.rightEyeOpenProb,
    required this.headTurnY,
    required this.headTiltZ,
    required this.nose,
    required this.leftEar,
    required this.rightEar,
    required this.mouthLeft,
    required this.mouthRight,
    required this.mouthBottom
  });
}
