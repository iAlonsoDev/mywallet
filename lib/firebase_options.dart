
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
    apiKey: 'AIzaSyCiJCh_F6p96DrQQiNWMj4tted-0nCgMmI',
    appId: '1:922424141325:web:589736d644029c6ffd9744',
    messagingSenderId: '922424141325',
    projectId: 'alonsodev-59063',
    authDomain: 'alonsodev-59063.firebaseapp.com',
    databaseURL: 'https://alonsodev-59063-default-rtdb.firebaseio.com',
    storageBucket: 'alonsodev-59063.firebasestorage.app',
    measurementId: 'G-6K79YXWRCV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvq1li-Qp2m62JQoLJlDbVHfRyHSgFWoc',
    appId: '1:922424141325:android:17544f24d7d0f5c2fd9744',
    messagingSenderId: '922424141325',
    projectId: 'alonsodev-59063',
    databaseURL: 'https://alonsodev-59063-default-rtdb.firebaseio.com',
    storageBucket: 'alonsodev-59063.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoAuuayfXXqqNCa5oG7qXz4Qk6ubFnZq0',
    appId: '1:922424141325:ios:37af6cf7b2658b3dfd9744',
    messagingSenderId: '922424141325',
    projectId: 'alonsodev-59063',
    databaseURL: 'https://alonsodev-59063-default-rtdb.firebaseio.com',
    storageBucket: 'alonsodev-59063.firebasestorage.app',
    iosBundleId: 'com.example.mywallet',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDoAuuayfXXqqNCa5oG7qXz4Qk6ubFnZq0',
    appId: '1:922424141325:ios:37af6cf7b2658b3dfd9744',
    messagingSenderId: '922424141325',
    projectId: 'alonsodev-59063',
    databaseURL: 'https://alonsodev-59063-default-rtdb.firebaseio.com',
    storageBucket: 'alonsodev-59063.firebasestorage.app',
    iosBundleId: 'com.example.mywallet',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCiJCh_F6p96DrQQiNWMj4tted-0nCgMmI',
    appId: '1:922424141325:web:1ec6be45daa52c74fd9744',
    messagingSenderId: '922424141325',
    projectId: 'alonsodev-59063',
    authDomain: 'alonsodev-59063.firebaseapp.com',
    databaseURL: 'https://alonsodev-59063-default-rtdb.firebaseio.com',
    storageBucket: 'alonsodev-59063.firebasestorage.app',
    measurementId: 'G-28JRRFF6V4',
  );

}