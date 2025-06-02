import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> uploadImageToStorage(XFile file, String uid) async {
  final filename = path.basename(file.path);
  final ref = FirebaseStorage.instance.ref().child(
    'moapp_final/$uid/$filename',
  );
  await ref.putFile(File(file.path));
  return await ref.getDownloadURL();
}

Future<void> saveToFirestoreWithImages({
  required XFile imageFile1,
  required XFile imageFile2,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final now = DateTime.now();

  final image1Url = await uploadImageToStorage(imageFile1, uid);
  final image2Url = await uploadImageToStorage(imageFile2, uid);

  await FirebaseFirestore.instance.collection('moapp_final').add({
    'uid': uid,
    'title': 'Sync Your Snap',
    'created': now,
    'modified': now,
    'image1Url': image1Url,
    'image2Url': image2Url,
    'isAnonymous': user.isAnonymous,
  });
}
