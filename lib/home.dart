import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, semanticLabel: 'prior'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('Sync Your Snap'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 스크롤 가능한 리스트
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: 20,
            itemBuilder:
                (context, index) => ListTile(
                  leading: const Icon(Icons.image),
                  title: Text('더미 아이템 ${index + 1}'),
                  subtitle: const Text('설명 텍스트'),
                ),
          ),

          // 고정 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/image');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 63, 151),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to image.dart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
