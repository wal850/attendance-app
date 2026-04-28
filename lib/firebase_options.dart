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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVClpr5HpIcpbf8LNO3PZR1zfxU6oM6f0',
    appId: '1:122633473706:android:ab8e1d13cf06a8f3b68ad3',
    messagingSenderId: '122633473706',
    projectId: 'gps-attendance-2026',
    storageBucket: 'gps-attendance-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVClpr5HpIcpbf8LNO3PZR1zfxU6oM6f0',
    appId: '1:122633473706:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '122633473706',
    projectId: 'gps-attendance-2026',
    storageBucket: 'gps-attendance-2026.firebasestorage.app',
    iosBundleId: 'com.retlaw.attendance',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAVClpr5HpIcpbf8LNO3PZR1zfxU6oM6f0',
    authDomain: 'gps-attendance-2026.firebaseapp.com',
    projectId: 'gps-attendance-2026',
    storageBucket: 'gps-attendance-2026.firebasestorage.app',
    messagingSenderId: '122633473706',
    appId: '1:122633473706:web:YOUR_WEB_APP_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAVClpr5HpIcpbf8LNO3PZR1zfxU6oM6f0',
    appId: '1:122633473706:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '122633473706',
    projectId: 'gps-attendance-2026',
    storageBucket: 'gps-attendance-2026.firebasestorage.app',
    iosBundleId: 'com.retlaw.attendance',
  );
}
