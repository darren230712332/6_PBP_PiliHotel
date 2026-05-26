import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHfsvCINbDIEY3ckHlI7WbT9KmZYVEKzA',
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:638218380503:android:fc2e765af1acec02fdfc92',
    ),
    messagingSenderId: '638218380503',
    projectId: 'pbp-pilihotel',
    authDomain: 'pbp-pilihotel.firebaseapp.com',
    storageBucket: 'pbp-pilihotel.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHfsvCINbDIEY3ckHlI7WbT9KmZYVEKzA',
    appId: '1:638218380503:android:fc2e765af1acec02fdfc92',
    messagingSenderId: '638218380503',
    projectId: 'pbp-pilihotel',
    storageBucket: 'pbp-pilihotel.firebasestorage.app',
  );
}
