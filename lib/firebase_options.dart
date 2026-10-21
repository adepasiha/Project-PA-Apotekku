// File ini biasanya dihasilkan secara otomatis oleh perintah flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
///
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase belum dikonfigurasi untuk iOS. Jalankan flutterfire configure.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase belum dikonfigurasi untuk macOS. Jalankan flutterfire configure.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase belum dikonfigurasi untuk Windows. Jalankan flutterfire configure.',
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeLyhTKF00wKCeEta0c2dCXehlIQwod0A',
    appId: '1:798415949995:web:661273d67201d03b8a27ee',
    messagingSenderId: '798415949995',
    projectId: 'apotekku-e15bc',
    authDomain: 'apotekku-e15bc.firebaseapp.com',
    storageBucket: 'apotekku-e15bc.firebasestorage.app',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGec34s9JsuU0LkahFAIJBT7HIQHl7SKs',
    appId: '1:798415949995:android:b5eb8e6d0f743af18a27ee',
    messagingSenderId: '798415949995',
    projectId: 'apotekku-e15bc',
    storageBucket: 'apotekku-e15bc.firebasestorage.app',
  );
}
