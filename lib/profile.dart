import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃 하시겠습니까?'),
            content: const Text('로그아웃하면 앱을 다시 시작해야 로그인할 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      logoutAndCleanupIfAnonymous();
      final user = FirebaseAuth.instance.currentUser;
      // 로그아웃 처리
      if (user != null && !user.isAnonymous) {
        // 구글 로그인 캐시도 함께 삭제
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }

      // Firebase 로그아웃
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> logoutAndCleanupIfAnonymous() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.isAnonymous) {
      final uid = user.uid;

      // 1. comparison_results 컬렉션에서 uid 일치하는 문서 삭제
      final compDocs =
          await FirebaseFirestore.instance
              .collection('comparison_results')
              .where('uid', isEqualTo: uid)
              .get();

      for (var doc in compDocs.docs) {
        await doc.reference.delete();
      }

      // 2. users 컬렉션에서 uid 일치하는 문서 삭제
      final userDocs =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: uid)
              .get();

      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;
    final displayName = isAnonymous ? 'Guest' : (user?.displayName ?? 'User');
    final profileImage = isAnonymous ? null : user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 프로필 이미지
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileImage != null
                      ? NetworkImage(profileImage)
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(height: 20),

            // 이름
            Text(
              displayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 로그인 방식
            Text(
              isAnonymous ? 'Guest Login' : 'Google Login',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),

            const Spacer(),

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _signOut(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
