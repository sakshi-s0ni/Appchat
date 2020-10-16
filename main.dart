import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/chat.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/reg.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "home",
      routes: {
        "home": (context) => MyHome(),
        "reg": (context) => MyReg(),
        "login": (context) => MyLogin(),
        "chat": (context) => MyChat(),
        // "myimage": (context) => MyImage(),
      },
    ),
  );
}
