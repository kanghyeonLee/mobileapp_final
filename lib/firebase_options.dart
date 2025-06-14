import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0LasTA4-HRjxmm09pZmMbxaKglsE8LYQ',
    appId: '1:592180494255:web:1905d3eb6cf488e2b0395a',
    messagingSenderId: '592180494255',
    projectId: 'mobileappfinal-e4608',
    authDomain: 'mobileappfinal-e4608.firebaseapp.com',
    storageBucket: 'mobileappfinal-e4608.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcLqU5TQLFN3Gl2-ft1R6CKI00H8o3JMs',
    appId: '1:592180494255:android:325a60a5aeabbd7fb0395a',
    messagingSenderId: '592180494255',
    projectId: 'mobileappfinal-e4608',
    storageBucket: 'mobileappfinal-e4608.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeLF-MWkY24nuGAkihiKHPjvFf-e1oROw',
    appId: '1:592180494255:ios:5a2840d6ec827b73b0395a',
    messagingSenderId: '592180494255',
    projectId: 'mobileappfinal-e4608',
    storageBucket: 'mobileappfinal-e4608.firebasestorage.app',
    androidClientId:
        '592180494255-6v68dn6qmhmhthcq71dlhip1ijnnm91o.apps.googleusercontent.com',
    iosClientId:
        '592180494255-3m141ejsjt80qqemf55385fm51gs7kgc.apps.googleusercontent.com',
    iosBundleId: 'com.example.mobileappFinal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeLF-MWkY24nuGAkihiKHPjvFf-e1oROw',
    appId: '1:592180494255:ios:5a2840d6ec827b73b0395a',
    messagingSenderId: '592180494255',
    projectId: 'mobileappfinal-e4608',
    storageBucket: 'mobileappfinal-e4608.firebasestorage.app',
    androidClientId:
        '592180494255-6v68dn6qmhmhthcq71dlhip1ijnnm91o.apps.googleusercontent.com',
    iosClientId:
        '592180494255-3m141ejsjt80qqemf55385fm51gs7kgc.apps.googleusercontent.com',
    iosBundleId: 'com.example.mobileappFinal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0LasTA4-HRjxmm09pZmMbxaKglsE8LYQ',
    appId: '1:592180494255:web:aaa98f0bb47c0cfeb0395a',
    messagingSenderId: '592180494255',
    projectId: 'mobileappfinal-e4608',
    authDomain: 'mobileappfinal-e4608.firebaseapp.com',
    storageBucket: 'mobileappfinal-e4608.firebasestorage.app',
  );
}
