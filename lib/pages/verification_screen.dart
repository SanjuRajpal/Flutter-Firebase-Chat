import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/beans/VerificationArguments.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/utils/Snackbar.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:flutter_app/widgets/pin_entry_text_field.dart';

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _otp = "";
  VerificationArgument _argument;
  bool _showLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _argument = ModalRoute.of(context).settings.arguments;
    print(_argument);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: App.primaryColorDark,
      appBar: Utils.getAppBar(context, App.verification),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _showLoading ? LinearProgressIndicator() : Container(),
                Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 20),
                  child: Text(
                    App.verify +
                        _argument.phoneNumber +
                        '\n' +
                        App.phone_number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
                PinEntryTextField(
                  fields: 6,
                  showFieldAsBox: false,
                  onSubmit: (String pin) {
                    _otp = pin;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    App.enter_digits_of_otp,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: RaisedButton(
                    padding: EdgeInsets.all(7),
                    color: Colors.white,
                    onPressed: () {
                      _doVerifyPhoneNumber();
                    },
                    child: Text(
                      App.verify_number,
                      style: TextStyle(fontSize: 14, color: App.black),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _doVerifyPhoneNumber() {
    if (_otp.length != 6) {
      Utils.hideKeyBoard(context);
      Snackbar.show(_scaffoldKey, App.invalid_otp);
    } else {
      setState(() {
        _showLoading = true;
      });
      _auth.currentUser().then((user) {
        _signIn();
      });
    }
  }

  void _signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _argument.verificationId,
        smsCode: _otp,
      );
      final AuthResult result = await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(result.user.uid == currentUser.uid);

      var user = await FirebaseHelper.checkIfUserExits(_argument.phoneNumber);
      if (user == null)
        MyNavigator.goToEditProfile(context, _argument.phoneNumber);
      else {
        // store user's details into preference
        MyPrefs.putString(Keys.USER_ID, user.userId);
        MyPrefs.putString(Keys.PHONE_NUMBER, user.phoneNumber);
        MyPrefs.putString(Keys.FIRST_NAME, user.firstName);
        MyPrefs.putString(Keys.LAST_NAME, user.lastName);
        MyPrefs.putBoolean(Keys.IS_USER_LOGIN, true);

        // move user to home screen
        MyNavigator.goToHome(context);
      }

      setState(() {
        _showLoading = false;
      });
    } catch (e) {
      setState(() {
        _showLoading = false;
      });
      switch (e.code) {
        case 'ERROR_INVALID_VERIFICATION_CODE':
          Snackbar.show(_scaffoldKey, App.invalid_otp);
          break;
        case 'ERROR_NETWORK_REQUEST_FAILED':
          Snackbar.show(_scaffoldKey, App.error_internet_connection);
          break;
        default:
          Snackbar.show(_scaffoldKey, App.error_something_wrong);
          break;
      }
      print('ERROR => ' + e.toString());
    }
  }
}
