// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrVIHbk6AIAJIC_bDdcfF0lXO7iavG5ZU',
    appId: '1:5379082267:android:fe09ec00f3e7db039290be',
    messagingSenderId: '5379082267',
    projectId: 'online-care',
    databaseURL: 'https://online-care.firebaseio.com',
    storageBucket: 'online-care.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCumghbY6i97SPwPFaay6o3hSMUp-9KGj8',
    appId: '1:5379082267:ios:5db381a395f5c8519290be',
    messagingSenderId: '5379082267',
    projectId: 'online-care',
    databaseURL: 'https://online-care.firebaseio.com',
    storageBucket: 'online-care.appspot.com',
    androidClientId: '5379082267-0894qm517ho9nvbc3hrff204ed1ogams.apps.googleusercontent.com',
    iosClientId: '5379082267-mmiurf6t6tfekuorai4c1cmto6ubmlvl.apps.googleusercontent.com',
    iosBundleId: 'com.digihealthcard',
  );
}
