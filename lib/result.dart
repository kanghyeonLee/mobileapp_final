import 'dart:math';

import 'package:flutter/material.dart';
import 'model/imageobj.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double getMouthGap(
      List<Point<int>> upper,
      List<Point<int>> lower,
      ImageObj image,
    ) {
      if (upper.isEmpty || lower.isEmpty) return 0.0;
      final centerUpper = upper[upper.length ~/ 2];
      final centerLower = lower[lower.length ~/ 2];
      final mouthGap = (centerUpper.y - centerLower.y).abs();
      final faceHeight = image.face.boundingBox.height;
      return mouthGap / faceHeight;
    }

    double getEyebrowGap(
      List<Point<int>> leftEyebrow,
      List<Point<int>> rightEyebrow,
      ImageObj image,
    ) {
      if (leftEyebrow.isEmpty || rightEyebrow.isEmpty) return 0.0;

      final centerLeft = leftEyebrow[leftEyebrow.length ~/ 2];
      final centerRight = rightEyebrow[rightEyebrow.length ~/ 2];

      final browGap = (centerLeft.y - centerRight.y).abs();
      final faceHeight = image.face.boundingBox.height;

      return browGap / faceHeight;
    }

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final ImageObj image1 = args['image1'];
    final ImageObj image2 = args['image2'];
    final upperLipBottom1 = image1.upperLipBottom.points;
    final lowerLipTop1 = image1.lowerLipTop.points;
    final upperLipBottom2 = image2.upperLipBottom.points;
    final lowerLipTop2 = image2.lowerLipTop.points;
    final mouthGap1 = getMouthGap(upperLipBottom1, lowerLipTop1, image1);
    final mouthGap2 = getMouthGap(upperLipBottom2, lowerLipTop2, image2);
    final leftEyebrow1 = image1.leftEyebrowTop.points;
    final rightEyebrow1 = image1.rightEyebrowTop.points;
    final leftEyebrow2 = image2.leftEyebrowTop.points;
    final rightEyebrow2 = image2.rightEyebrowTop.points;

    final eyebrowGap1 = getEyebrowGap(leftEyebrow1, rightEyebrow1, image1);
    final eyebrowGap2 = getEyebrowGap(leftEyebrow2, rightEyebrow2, image2);
    final List<String> labels = [
      'Smile',
      'Left Eye Open',
      'Right Eye Open',
      'Mouth Gap',
      'Eyebrow Gap',
    ];

    final List<double> values1 = [
      image1.smiling,
      image1.leftEyeOpenProb,
      image1.rightEyeOpenProb,
      mouthGap1,
      eyebrowGap1,
    ];

    final List<double> values2 = [
      image2.smiling,
      image2.leftEyeOpenProb,
      image2.rightEyeOpenProb,
      mouthGap2,
      eyebrowGap2,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Comparison Result")),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: List.generate(labels.length, (index) {

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Row(
                            children: [
                              Text(
                                "Image 1",
                                style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                             
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "Image 2",
                                style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              
                            ],
                          ),
                        ],
                      ),
                  
                     
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: values1[index].clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, _) {
                                final color = Color.lerp(Colors.red, Colors.green, value);
                                return Stack(
                                  children: [
                                    Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: value,
                                      child: Container(

            
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),

                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                           
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: values2[index].clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, _) {
                                final color = Color.lerp(Colors.red, Colors.green, value);
                                return Stack(
                                  children: [
                                    Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),

                                      FractionallySizedBox(
                                        widthFactor: value,
                                        child: Container(
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),

                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              // image2 bar
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: values2[index].clamp(0.0, 1.0),
                                ),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, _) {
                                  final color = Color.lerp(
                                    Colors.red,
                                    Colors.green,
                                    value,
                                  );
                                  return Stack(
                                    children: [
                                      Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),

                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  
                      const SizedBox(width: 12),
                  
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${(values1[index] * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                             
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "${(values2[index] * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),

                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 오른쪽 퍼센트 + 아이콘
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${(values1[index] * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "${(values2[index] * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 102, 204),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to home.dart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
