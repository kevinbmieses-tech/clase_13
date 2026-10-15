import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError('Firebase is configured for Android and web.');
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDUqXBO8gBGVCQDOrgrHMDKkvC4vw-_guE',
    appId: '1:777814525434:web:fa6afec28a4a5ced4f5043',
    messagingSenderId: '777814525434',
    projectId: 'donar-sangre-intec',
    authDomain: 'donar-sangre-intec.firebaseapp.com',
    storageBucket: 'donar-sangre-intec.firebasestorage.app',
  );
  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDUqXBO8gBGVCQDOrgrHMDKkvC4vw-_guE',
    appId: '1:777814525434:android:ba9bee61b80f0eb54f5043',
    messagingSenderId: '777814525434',
    projectId: 'donar-sangre-intec',
    storageBucket: 'donar-sangre-intec.firebasestorage.app',
  );
}
