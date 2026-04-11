// File generated from `android/app/google-services.json` (project jango-market-8c4dd).
// For iOS push, add `GoogleService-Info.plist` and extend [ios] via FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Add GoogleService-Info.plist and run FlutterFire configure for iOS/macOS.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzAHXYxQry9rZFPIdtOW1QMJEhqVAPE_Y',
    appId: '1:118142612386:android:48b5b3c4ee1dd5faf278fb',
    messagingSenderId: '118142612386',
    projectId: 'jango-market-8c4dd',
    storageBucket: 'jango-market-8c4dd.firebasestorage.app',
  );
}
