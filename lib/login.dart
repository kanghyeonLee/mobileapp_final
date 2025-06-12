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
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 166, 218, 244),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              const SizedBox(height: 60),
              Column(
                children: [
                  Image.asset('assets/logo.png', width: 120, height: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'Sync Your Snap',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Rock_Salt',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: 'example@email.com',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: 'At least 6 characters',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/forgot-password');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // Sign in 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;

                    try {
                      final userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                      if (userCredential.user != null) {
                        await saveUserInfo(userCredential.user!);
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } on FirebaseAuthException catch (e) {
                      String message;
                      if (e.code == 'user-not-found') {
                        message = 'No user found for that email.';
                      } else if (e.code == 'wrong-password') {
                        message = 'Wrong password provided.';
                      } else {
                        message = 'Login failed: ${e.message}';
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                  child: const Text(
                    'Sign in',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white30)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white30)),
                ],
              ),
              const SizedBox(height: 16),

              // Google 로그인 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final userCredential = await signInWithGoogle();
                          if (userCredential.user != null) {
                            await saveUserInfo(userCredential.user!);
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google login failed'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google.png'),
                          const Text('Google'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Guest 로그인 버튼
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => signInAnonymous(),
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                      label: const Text('Guest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
