import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

import 'locator.dart';

import '../app.dart';

@pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(
    LocatorConfig(
      authority: const String.fromEnvironment("AUTHORITY"),
      imageBaseUrl: const String.fromEnvironment("IMAGE_BASE_URL"),
      paymentRedirectUrl: const String.fromEnvironment("PAYMENT_REDIRECT_URL"),
      paymentGatewayEndpoint: const String.fromEnvironment("PAYMENT_GATEWAY_ENDPOINT"),
      webBaseUrl: const String.fromEnvironment("WEB_BASE_URL"),
      weatherApiKey: const String.fromEnvironment("WEATHER_API_KEY"),
      googleMapApiKey: const String.fromEnvironment("GOOGLE_MAP_API_KEY"),
      googlePlacesApiKey: const String.fromEnvironment("GOOGLE_PLACES_API_KEY"),
      googleClientId: switch (defaultTargetPlatform) {
        (TargetPlatform.android) => const String.fromEnvironment("GOOGLE_CLIENT_ID_ANDROID"),
        (TargetPlatform.iOS) => const String.fromEnvironment("GOOGLE_CLIENT_ID_IOS"),
        _ => throw UnsupportedError(
            'GoogleAuth not supported for this platform.',
          ),
      },
    ),
  );

  // await Firebase.initializeApp(
  //   options: switch (defaultTargetPlatform) {
  //     (TargetPlatform.android) => const FirebaseOptions(
  //         apiKey: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_APIKEY"),
  //         appId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_APP_ID"),
  //         messagingSenderId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_MESSAGING_SENDER_ID"),
  //         projectId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_PROJECT_ID"),
  //         storageBucket: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_STORAGE_BUCKET"),
  //       ),
  //     (TargetPlatform.iOS) => const FirebaseOptions(
  //         apiKey: String.fromEnvironment("FIREBASE_OPTIONS_IOS_APIKEY"),
  //         appId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_APP_ID"),
  //         messagingSenderId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_MESSAGING_SENDER_ID"),
  //         projectId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_PROJECT_ID"),
  //         storageBucket: String.fromEnvironment("FIREBASE_OPTIONS_IOS_STORAGE_BUCKET"),
  //         iosBundleId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_BUNDLE_ID"),
  //       ),
  //     _ => throw UnsupportedError(
  //         'DefaultFirebaseOptions are not supported for this platform.',
  //       ),
  //   },
  // );

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const App());
}
