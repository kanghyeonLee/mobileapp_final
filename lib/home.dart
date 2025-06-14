import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imagePaths = [
      'assets/image1.png',
      'assets/image2.jpg',
      'assets/image3.jpeg',
      'assets/image4.png',
    ];
    final _carouselController = CarouselController();
    int _currentIndex = 0;

    void onComparePressed() {
      final selectedImage = imagePaths[_currentIndex];
      Navigator.pushNamed(
        context,
        '/image',
        arguments: selectedImage, // 전달
      );
    }

    void onSkipPressed() {
      Navigator.pushNamed(context, '/image');
    }


  @override
  Widget build(BuildContext context) {
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
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Rock_Salt'),
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
      body: Column(
        children: [
          const SizedBox(height: 180,),
          const Text('지금 당장 여러분의 표정을 이 이미지들과 sync해보세요!'),
          const SizedBox(height: 30,),
          CarouselSlider(
            options: CarouselOptions(
              height: 300.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              aspectRatio: 16 / 9,
              onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            ),
            items: imagePaths.map((path) {
              return Builder(
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              ElevatedButton(
                onPressed: onComparePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('이 이미지로 얼굴 비교하기'),
              ),
              const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onSkipPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('그냥 테스트'),
                ),
              ],
            )
        ],
      ),
    );
  }
}
