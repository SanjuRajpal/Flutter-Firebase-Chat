import 'package:flutter/material.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/beans/VerificationArguments.dart';
import 'package:flutter_app/pages/conversation_page.dart';

class MyNavigator {
  static void goToSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/splash");
  }

  static void goToSignIn(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/signIn", (r) => false);
  }

  static void goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/home");
  }

  static void goToPrivacyPolicy(BuildContext context, String title) {
    Navigator.pushNamed(context, "/privacyPolicy", arguments: title);
  }

  static void goToPhoneVerification(BuildContext context,
      VerificationArgument argument) {
    Navigator.pushReplacementNamed(context, "/phoneVerification",
        arguments: argument);
  }

  static void goToIntroduction(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/introduction");
  }

  static void goToEditProfile(BuildContext context, String phoneNumber) {
    Navigator.pushReplacementNamed(context, "/editProfile",
        arguments: phoneNumber);
  }

  static void goToSettings(BuildContext context) {
    Navigator.pushNamed(context, "/settings");
  }

  static void goToNewChat(BuildContext context) {
    Navigator.pushNamed(context, "/newChat");
  }

  static void goToConversations(BuildContext context, User user) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Conversations(user: user,)));
  }
}
