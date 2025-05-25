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

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymous() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                const SizedBox(height: 16.0),
                const Text('Sync Your Snap'),
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
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      // 로그인 취소됨
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 취소되었습니다.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
                    );
                    print('\n\n@@@@@@@@@@@@@@Login failed: $e\n\n');
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
                  Navigator.pushReplacementNamed(context, '/');
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
