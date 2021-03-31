import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/MyNavigator.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: App.primaryColorDark,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            App.welcome,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                          Text(
                            App.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                    )),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          child: Image.asset('assets/images/ic_logo.png'),
                          radius: 80,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 20, left: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: TextStyle(fontSize: 16, color: App.white),
                              children: <TextSpan>[
                                TextSpan(text: App.read_our),
                                TextSpan(
                                    text: App.privacy_policy,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () =>
                                          MyNavigator.goToPrivacyPolicy(
                                              context, App.privacy_policy)),
                                TextSpan(text: App.tap_to_agree),
                                TextSpan(
                                    text: App.terms_of_use,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () =>
                                          MyNavigator.goToPrivacyPolicy(
                                              context, App.terms_of_use)),
                              ]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: RaisedButton(
                          padding: EdgeInsets.all(7),
                          color: Colors.white,
                          onPressed: () {
                            MyNavigator.goToIntroduction(context);
                          },
                          child: Text(
                            App.agree_and_continue,
                            style: TextStyle(fontSize: 14, color: App.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
