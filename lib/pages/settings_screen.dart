import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var _fullName = "";
  var _profileUrl = "";
  File _image;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    var first = await MyPrefs.getString(Keys.FIRST_NAME);
    var last = await MyPrefs.getString(Keys.LAST_NAME);
    var profile = await MyPrefs.getString(Keys.PROFILE);
    setState(() {
      _fullName = first + " " + last;
      _profileUrl = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(context, App.settings),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Container(
                color: App.primaryColorLight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      child: ClipOval(
                        child: _image == null
                            ? Image.network(
                                _profileUrl,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _image,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        _fullName,
                        style: TextStyle(fontSize: 16, color: App.black),
                      ),
                    )
                  ],
                ),
              ),
              width: double.infinity,
              height: 180,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.border_color),
                    title: Text(App.edit_profile),
                    onTap: _doEditProfile,
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text(App.notifications),
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment),
                    title: Text(App.privacy_policy),
                    onTap: () => MyNavigator.goToPrivacyPolicy(
                        context, App.privacy_policy),
                  ),
                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text(App.terms_of_use),
                    onTap: () => MyNavigator.goToPrivacyPolicy(
                        context, App.terms_of_use),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text(App.about_us),
                    onTap: () =>
                        MyNavigator.goToPrivacyPolicy(context, App.about_us),
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text(App.logout),
                    onTap: _doLogout,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _doEditProfile() {
    MyNavigator.goToEditProfile(context, null);
  }

  Future _showImagePicker() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Camera"),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery"),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));
    if (imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource);
      if (file != null) {
        setState(() => _image = file);

        FirebaseHelper.uploadImage(_image);
      }
    }
  }

  void _doLogout() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(App.are_you_sure_want_to_logout,
                  style: TextStyle(
                      fontSize: 16,
                      color: App.black,
                      fontWeight: FontWeight.w300)),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(App.cancel,
                      style: TextStyle(
                          fontSize: 16,
                          color: App.black,
                          fontWeight: FontWeight.w300)),
                ),
                MaterialButton(
                  onPressed: () {
                    MyPrefs.clearPref();
                    MyNavigator.goToSignIn(context);
                  },
                  child: Text(App.logout,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w300)),
                )
              ],
            ));
  }
}
