import 'package:flutter/material.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/enums/enums.dart';

class Launcher extends StatefulWidget {
  @override
  _LauncherState createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  @override
  void initState() {
    var isLogin = MyPrefs.getBoolean(Keys.IS_USER_LOGIN);

    isLogin.then((bool login) {
      print(login);
      if (login) {
        MyNavigator.goToHome(context);
      } else {
        MyNavigator.goToSplash(context);
      }
    }).catchError((onError) {
      print('Error ' + onError.toString());
      MyNavigator.goToSplash(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: App.primaryColor,
      ),
    );
  }
}
