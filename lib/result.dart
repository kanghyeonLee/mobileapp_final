import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'model/imageobj.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final titleController = TextEditingController();
  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

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
    final user = FirebaseAuth.instance.currentUser;
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

    Future<String> uploadImageToStorage(
      String filePath,
      String fileName,
    ) async {
      final ref = FirebaseStorage.instance.ref().child(
        'comparison_images/$fileName',
      );
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    }

    Future<void> saveResultToFirestore(ImageObj image1, ImageObj image2) async {
      if (user == null) return;
      try {
        final url1 = await uploadImageToStorage(
          image1.filePath,
          'image1_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        final url2 = await uploadImageToStorage(
          image2.filePath,
          'image2_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await FirebaseFirestore.instance.collection('comparison_results').add({
          'timestamp': FieldValue.serverTimestamp(),
          'image1': {
            'smiling': image1.smiling,
            'leftEyeOpen': image1.leftEyeOpenProb,
            'rightEyeOpen': image1.rightEyeOpenProb,
            'mouthGap': getMouthGap(
              image1.upperLipBottom.points,
              image1.lowerLipTop.points,
              image1,
            ),
            'eyebrowGap': getEyebrowGap(
              image1.leftEyebrowTop.points,
              image1.rightEyebrowTop.points,
              image1,
            ),
            'url': url1,
          },
          'image2': {
            'smiling': image2.smiling,
            'leftEyeOpen': image2.leftEyeOpenProb,
            'rightEyeOpen': image2.rightEyeOpenProb,
            'mouthGap': getMouthGap(
              image2.upperLipBottom.points,
              image2.lowerLipTop.points,
              image2,
            ),
            'eyebrowGap': getEyebrowGap(
              image2.leftEyebrowTop.points,
              image2.rightEyebrowTop.points,
              image2,
            ),
            'url': url2,
          },
          'uid': user.uid,
          'isAnonymous': user.isAnonymous,
          'created': FieldValue.serverTimestamp(),
          'modified': FieldValue.serverTimestamp(),
          'title':
              titleController.text.trim().isNotEmpty
                  ? titleController.text.trim()
                  : 'Sync Your Snap',
        });
      } catch (e) {
        debugPrint("Firestore save error: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Your Snap'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 166, 218, 244)),
              child: Text(
                '메뉴',
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12,
                ),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a title',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              ...List.generate(labels.length, (index) {
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
                      const SizedBox(height: 10),
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
                                    "Image 2",
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

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: values1[index].clamp(0.0, 1.0),
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
                                        FractionallySizedBox(
                                          widthFactor: value,
                                          child: Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),

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
                                        FractionallySizedBox(
                                          widthFactor: value,
                                          child: Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final shouldSave = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('결과 저장'),
                          content: const Text('Firestore에 저장하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('아니오'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('네'),
                            ),
                          ],
                        ),
                  );

                  if (shouldSave == true) {
                    // 저장 중 로딩창 띄우기
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 사용자가 백키로 닫지 못하게
                      builder:
                          (context) => const AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text("저장 중입니다..."),
                              ],
                            ),
                          ),
                    );

                    // 저장 실행
                    await saveResultToFirestore(image1, image2);

                    // 로딩창 닫기
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved to Firestore!')),
                    );
                  }

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
                child: const Text('저장하기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
