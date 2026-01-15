// File: lib/firebase_options.dart
// GANTI SELURUH ISI FILE INI!

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// ✅ Firebase Options dari google-services.json
/// Project: konseling-dc383
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  /// Android Configuration dari google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHGWqgGkEXS7Sy35w_ke13SfrAPytlQOs',
    appId: '1:1069183722238:android:4cdf5703fa4d970086fbaf',
    messagingSenderId: '1069183722238',
    projectId: 'konseling-dc383',
    storageBucket: 'konseling-dc383.firebasestorage.app',
  );

  /// iOS Configuration (sesuaikan jika ada)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHGWqgGkEXS7Sy35w_ke13SfrAPytlQOs',
    appId: '1:1069183722238:ios:4cdf5703fa4d970086fbaf',
    messagingSenderId: '1069183722238',
    projectId: 'konseling-dc383',
    storageBucket: 'konseling-dc383.firebasestorage.app',
    iosBundleId: 'com.company.konseling',
  );

  /// Web Configuration (sesuaikan jika ada)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHGWqgGkEXS7Sy35w_ke13SfrAPytlQOs',
    appId: '1:1069183722238:web:4cdf5703fa4d970086fbaf',
    messagingSenderId: '1069183722238',
    projectId: 'konseling-dc383',
    authDomain: 'konseling-dc383.firebaseapp.com',
    storageBucket: 'konseling-dc383.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // Opsional untuk Analytics
  );
}