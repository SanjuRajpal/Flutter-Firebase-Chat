import 'package:flutter/material.dart';
import 'package:flutter_app/pages/launcher_screen.dart';
import 'package:flutter_app/pages/new_chat_screen.dart';
import 'package:flutter_app/pages/settings_screen.dart';
import 'package:flutter_app/pages/verification_screen.dart';
import 'package:flutter_app/utils/App.dart';

import 'pages/edit_profile_screen.dart';
import 'pages/home_screen.dart';
import 'pages/introduction_screen.dart';
import 'pages/privacy_screen.dart';
import 'pages/signIn_screen.dart';
import 'pages/splash_screen.dart';

var routes = <String, WidgetBuilder>{
  "/splash": (BuildContext context) => Splash(),
  "/home": (BuildContext context) => Home(),
  "/introduction": (BuildContext context) => Introduction(),
  "/signIn": (BuildContext context) => SignIn(),
  "/privacyPolicy": (BuildContext context) => PrivacyPolicy(),
  "/phoneVerification": (BuildContext context) => Verification(),
  "/editProfile": (BuildContext context) => EditProfile(),
  "/settings": (BuildContext context) => Settings(),
  "/newChat": (BuildContext context) => NewChat(),
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    supportedLocales: [
      Locale('en'),
      Locale('it'),
      Locale('en'),
    ],
    theme: ThemeData(
        primaryColorDark: Color.fromRGBO(69, 90, 100, 1),
        primaryColorLight: Color.fromRGBO(207, 216, 220, 1),
        primaryColor: Color.fromRGBO(96, 125, 139, 1),
        accentColor: Color.fromRGBO(158, 158, 158, 1),
        textTheme: TextTheme(
                body1: TextStyle(fontSize: 16), body2: TextStyle(fontSize: 16))
            .apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: App.white, fontSize: 14.0),
        ),
        dividerColor: Color.fromRGBO(189, 189, 189, 1)),
    home: Launcher(),
    debugShowCheckedModeBanner: false,
    routes: routes,
  ));
}
