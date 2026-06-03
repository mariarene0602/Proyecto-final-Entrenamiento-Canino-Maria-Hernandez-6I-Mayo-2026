import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android; // fallback – no iOS config yet
      default:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpQwi8ztxDxOWGOA3RCXpY07sSAQWTdmY',
    appId: '1:741910018297:android:eab455004c65d0f3ae8a28',
    messagingSenderId: '741910018297',
    projectId: 'canis-academia-proyecto-final',
    storageBucket: 'canis-academia-proyecto-final.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAf0epnlOI8R4YfMsdJ2P0qGsHE3V3CErk',
    authDomain: 'canis-academia-proyecto-final.firebaseapp.com',
    appId: '1:741910018297:web:020b1e2329c4c67dae8a28',
    messagingSenderId: '741910018297',
    projectId: 'canis-academia-proyecto-final',
    storageBucket: 'canis-academia-proyecto-final.firebasestorage.app',
  );
}