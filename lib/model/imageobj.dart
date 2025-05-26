import 'package:flutter/widgets.dart';

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
  ImageObj({
    required this.title,
    required this.image,
    required this.smiling,
    required this.leftEyeOpenProb,
    required this.rightEyeOpenProb,
    required this.headTurnY,
    required this.headTiltZ,
  });
}
