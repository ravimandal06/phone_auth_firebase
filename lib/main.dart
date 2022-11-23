import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home.dart';
import 'phone_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA-K6Xg_kZXyDaapYfiHs-KA_I8mzqJSzY',
      appId: '1:251813202482:android:dda007c0d658d9da248a2b',
      messagingSenderId: '251813202482',
      projectId: 'phoneverify-cd3be',
      storageBucket: "phoneverify-cd3be.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: 'Flutter Firebase Phone Auth',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            // home: PhoneAuthPage(),
            // NOTE: This will check if the user is already signed in
            home: StreamBuilder<User?>(
                stream: firebaseAuth.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return HomePage();
                  }
                  return PhoneAuthPage();
                }),
          );
        });
  }
}
