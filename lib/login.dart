import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    if (userCredential.user != null) {
      await saveUserInfo(userCredential.user!); // 추가
      Navigator.pushReplacementNamed(context, '/home');
    }

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymous() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    await saveUserInfo(userCredential.user!); // 추가
    Navigator.pushReplacementNamed(context, '/home');
    return userCredential;
  }

  Future<void> saveUserInfo(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'isAnonymous': user.isAnonymous,
      'created': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };

    // Google 사용자라면 이메일과 이름도 저장
    if (!user.isAnonymous) {
      if (user.email != null) {
        userData['email'] = user.email!;
      }
      if (user.displayName != null) {
        userData['displayName'] = user.displayName!;
      }
    }

    await docRef.set(userData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 166, 218, 244),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                const SizedBox(height: 16.0),
                Image.asset(
                    'assets/logo.png',
                    width: 200,
                    height: 200,  
                  ),
                Text(
                  'Sync Your Snap',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily:'Rock_Salt',
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 120.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final userCredential = await signInWithGoogle();
                    if (userCredential.user != null) {
                      await saveUserInfo(userCredential.user!);
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 취소되었습니다.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                label: const Text("GOOGLE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  signInAnonymous();
                },
                icon: const Icon(Icons.question_mark, color: Colors.black),
                label: const Text("GUEST"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
