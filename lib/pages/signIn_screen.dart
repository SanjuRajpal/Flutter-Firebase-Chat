import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/beans/VerificationArguments.dart';
import 'package:flutter_app/countryCodePicker/country_code_picker.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/Snackbar.dart';
import 'package:flutter_app/utils/Utils.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _countryCode = App.default_country_code;
  String _phoneNo;
  String _verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _showLoading = false;

  Future<void> _sendOTP() async {
    print(_showLoading);
    Utils.hideKeyBoard(context);
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this._verificationId = verId;
      setState(() {
        _showLoading = false;
      });
      MyNavigator.goToPhoneVerification(
          context, VerificationArgument(_verificationId, _phoneNo));
    };

    try {
      _phoneNo = _countryCode + _phoneNo;

      _auth.verifyPhoneNumber(
          phoneNumber: _phoneNo,
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential authCredential) {
            print(authCredential);
          },
          verificationFailed: (AuthException exception) {
            print(exception.message + " ==> " + exception.code);
            setState(() {
              _showLoading = false;
            });
            switch (exception.code) {
              case 'verifyPhoneNumberError':
                Snackbar.show(_scaffoldKey, App.error_internet_connection);
                break;
              default:
                Snackbar.show(_scaffoldKey, App.error_something_wrong);
                break;
            }
          },
          codeSent: smsOTPSent,
          codeAutoRetrievalTimeout: (String id) => _verificationId = id);
    } catch (e) {
      switch (e.code) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: App.primaryColorDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _showLoading ? LinearProgressIndicator() : Container(),
                  Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 20),
                    child: Text(
                      App.enter_your_phone_number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Text(
                    App.we_will_be_verifying_number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: App.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, right: 10),
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CountryCodePicker(
                          onChanged: _onCountryChange,
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: App.white,
                          ),
                          initialSelection: App.default_country,
                          favorite: [
                            App.default_country_code,
                            App.default_country
                          ],
                          showFlag: false,
                          showFlagDialog: true,
                        ),
                        Flexible(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return App.error_required;
                                } else if (value.length != 10) {
                                  return App.invalid_phone_number;
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 16, color: App.white),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              onChanged: (value) {
                                this._phoneNo = value;
                              },
                              decoration: InputDecoration(
                                  hintStyle:
                                  TextStyle(fontSize: 16, color: App.white),
                                  hintText: App.enter_phone_number,
                                  counterText: "",
                                  errorStyle:
                                  TextStyle(fontSize: 12, color: App.white),
                                  hoverColor: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: RaisedButton(
                      padding: EdgeInsets.all(7),
                      color: Colors.white,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _showLoading = true;
                          });
                          _sendOTP();
                        }
                      },
                      child: Text(
                        App.send_otp,
                        style: TextStyle(fontSize: 14, color: App.black),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    this._countryCode = countryCode.toString();
  }
}
