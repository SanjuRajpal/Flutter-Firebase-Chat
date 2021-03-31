import 'package:flutter/material.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/Utils.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  var _title = "";

  @override
  Widget build(BuildContext context) {
    _title = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: Utils.getAppBar(context, _title),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 16, left: 16, top: 10, bottom: 10),
          child: Text(
            App.lorem_ipsum,
            textScaleFactor: 1.2,
            style: TextStyle(fontSize: 18, color: App.black),
          ),
        ),
      ),
    );
  }
}
