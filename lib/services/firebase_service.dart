import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static Future<void> saveRecord({
    required String title,
    required String image1Url,
    required String image2Url,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final isAnonymous = user.isAnonymous;

    final recordData = {
      'uid': uid,
      'title': title,
      'image1Url': image1Url,
      'image2Url': image2Url,
      'created': FieldValue.serverTimestamp(),
      'modified': FieldValue.serverTimestamp(),
      'isAnonymous': isAnonymous,
    };

    await FirebaseFirestore.instance.collection('records').add(recordData);
  }
}
