import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

ImageObj? selectedImage1;
ImageObj? selectedImage2;

class ImageObj {
  final Face face;
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
  final FaceContour faceContour;
  final FaceContour leftEyebrowTop;
  final FaceContour leftEyebrowBottom;
  final FaceContour rightEyebrowTop;
  final FaceContour rightEyebrowBottom;
  final FaceContour leftEye;
  final FaceContour rightEye;
  final FaceContour upperLipTop;
  final FaceContour upperLipBottom;
  final FaceContour lowerLipTop;
  final FaceContour lowerLipBottom;
  final FaceContour noseBridge;
  final FaceContour noseBottom;

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
    required this.mouthBottom,
    required this.faceContour,
    required this.face,
    required this.leftEyebrowTop,
    required this.leftEyebrowBottom,
    required this.rightEyebrowTop,
    required this.rightEyebrowBottom,
    required this.leftEye,
    required this.rightEye,
    required this.upperLipTop,
    required this.upperLipBottom,
    required this.lowerLipTop,
    required this.lowerLipBottom,
    required this.noseBridge,
    required this.noseBottom,
  });
}
