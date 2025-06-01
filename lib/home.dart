// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, semanticLabel: 'prior'),
//           onPressed: () {
//             Navigator.pushReplacementNamed(context, '/login');
//           },
//         ),
//         title: const Text('Sync Your Snap'),
//         actions: <Widget>[
//           IconButton(
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, '/profile');
//             },
//             icon: const Icon(Icons.person),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // 스크롤 가능한 리스트
//           ListView.builder(
//             padding: const EdgeInsets.only(bottom: 80.0),
//             itemCount: 20,
//             itemBuilder:
//                 (context, index) => ListTile(
//                   leading: const Icon(Icons.image),
//                   title: Text('더미 아이템 ${index + 1}'),
//                   subtitle: const Text('설명 텍스트'),
//                 ),
//           ),

//           // 고정 버튼
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushReplacementNamed(context, '/image');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 12, 63, 151),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 32,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text('Go to image.dart'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Future<void> saveTestData() async {
  //   await FirebaseFirestore.instance.collection('test_collection').add({
  //     'message': 'Hello Firestore!',
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseFirestore.instance.app.options.projectId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Your Snap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('records')
                    .where('uid', isEqualTo: currentUserUid)
                    .orderBy('created', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('등록된 상품이 없습니다.'));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final title = doc['title'] ?? '제목 없음';
                  final imageUrl = doc['image1Url'] ?? '';
                  final created = (doc['created'] as Timestamp?)?.toDate();
                  final createdStr =
                      created != null
                          ? '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}'
                          : '날짜 없음';

                  return ListTile(
                    leading:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.image),
                    title: Text(title),
                    subtitle: Text(createdStr),
                  );
                },
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // saveTestData();
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
