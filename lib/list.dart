import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserUid = currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Your Snap'),
        backgroundColor: Color(0xFFA6DAF4),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
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
      body:
          currentUserUid == null
              ? const Center(child: Text('로그인된 사용자가 없습니다.'))
              : Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('comparison_results')
                            .where('uid', isEqualTo: currentUserUid)
                            .orderBy('created', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('등록된 결과가 없습니다.'));
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          late final Map<String, dynamic> data;

                          try {
                            data = doc.data() as Map<String, dynamic>;
                          } catch (e) {
                            print('doc.data() error: $e');
                            return const SizedBox(); // error일 경우 아무것도 안 보여줌
                          }

                          final title = data['title'] ?? '제목 없음';

                          final created =
                              (data['created'] as Timestamp?)?.toDate();
                          final createdStr =
                              created != null
                                  ? '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}'
                                  : '날짜 없음';

                          final image1Url =
                              (data['image1']?['url'] ?? '') as String;
                          final image2Url =
                              (data['image2']?['url'] ?? '') as String;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        image1Url.isNotEmpty
                                            ? Image.network(
                                              image1Url,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                            : const Icon(Icons.image, size: 60),
                                  ),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        image2Url.isNotEmpty
                                            ? Image.network(
                                              image2Url,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                            : const Icon(Icons.image, size: 60),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          createdStr,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          Navigator.pushReplacementNamed(context, '/image');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            12,
                            63,
                            151,
                          ),
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
