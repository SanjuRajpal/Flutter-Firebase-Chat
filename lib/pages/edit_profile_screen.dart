import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/utils/Snackbar.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String _phoneNumber;
  String _firstName;
  String _lastName;
  String _profileUrl;
  bool _isLogin;
  File _image;

  @override
  Widget build(BuildContext context) {
    _phoneNumber = ModalRoute
        .of(context)
        .settings
        .arguments;
    _init();
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
                  SizedBox(
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: _getImageWidget(),
                    ),
                    width: double.infinity,
                    height: 200,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return App.error_required;
                              } else if (value.length <= 2) {
                                return App.invalid_first_name;
                              }
                              return null;
                            },
                            onFieldSubmitted: (v) =>
                                FocusScope.of(context).nextFocus(),
                            style: TextStyle(fontSize: 16, color: App.white),
                            keyboardType: TextInputType.text,
                            maxLength: 20,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (value) {
                              _firstName = value;
                            },
                            initialValue: _firstName,
                            decoration: InputDecoration(
                                hintStyle:
                                TextStyle(fontSize: 16, color: App.white),
                                hintText: App.first_name,
                                counterText: "",
                                errorStyle:
                                TextStyle(fontSize: 12, color: App.white),
                                hoverColor: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return App.error_required;
                                } else if (value.length <= 2) {
                                  return App.invalid_last_name;
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 16, color: App.white),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 20,
                              onFieldSubmitted: (v) =>
                                  FocusScope.of(context).unfocus(),
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              onChanged: (value) {
                                _lastName = value;
                              },
                              initialValue: _lastName,
                              decoration: InputDecoration(
                                  hintStyle:
                                  TextStyle(fontSize: 16, color: App.white),
                                  hintText: App.last_name,
                                  counterText: "",
                                  errorStyle:
                                  TextStyle(fontSize: 12, color: App.white),
                                  hoverColor: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: RaisedButton(
                              padding: EdgeInsets.all(7),
                              color: Colors.white,
                              onPressed: () {
                                if (_image == null && !_isLogin) {
                                  Snackbar.show(
                                      _scaffoldKey, 'Please select image');
                                  return;
                                }
                                if (_formKey.currentState.validate()) {
                                  _createOrUpdateUser();
                                }
                              },
                              child: Text(
                                _isLogin ? 'Save Changes' : App.start_namaste,
                                style:
                                TextStyle(fontSize: 14, color: App.black),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget() {
    var view;
    if (_isLogin) {
      if (_profileUrl.isEmpty && _image != null) {
        view = Container(
          color: App.primaryColorLight,
          child: Icon(
            Icons.add_a_photo,
            color: App.white,
            size: 32,
          ),
        );
      } else {
        if (_image != null) {
          view = Image.file(
            _image,
            fit: BoxFit.cover,
          );
        } else {
          view = Image.network(
            _profileUrl,
            fit: BoxFit.cover,
          );
        }
      }
    } else {
      view = _image == null
          ? Container(
        color: App.primaryColorLight,
        child: Icon(
          Icons.add_a_photo,
          color: App.white,
          size: 32,
        ),
      )
          : Image.file(
        _image,
        fit: BoxFit.cover,
      );
    }

    return view;
  }

  void _init() async {
    _isLogin = await MyPrefs.getBoolean(Keys.IS_USER_LOGIN);
    if (_isLogin) {
      var profileUrl = await MyPrefs.getString(Keys.PROFILE);
      var firstName = await MyPrefs.getString(Keys.FIRST_NAME);
      var lastName = await MyPrefs.getString(Keys.LAST_NAME);
      var phoneNumber = await MyPrefs.getString(Keys.PHONE_NUMBER);

      setState(() {
        _profileUrl = profileUrl;
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
      });
    }
  }

  void _updateUser() async {
    var profile = "";
    if (_image != null) {
      profile = await FirebaseHelper.uploadImage(_image);
    } else {
      profile = _profileUrl;
    }

    var userId = await MyPrefs.getString(Keys.USER_ID);
    var user = User();
    user.userId = userId;
    user.firstName = _firstName;
    user.lastName = _lastName;
    user.phoneNumber = _phoneNumber;
    user.profilePicture = profile;
  }

  void _createOrUpdateUser() async {
    print("_createOrUpdateUser");
    var userId="";
    var profile = "";
    if(_isLogin)
      userId = await MyPrefs.getString(Keys.USER_ID);

    else {
      // create or update user and store into firebase database
      userId = new DateTime.now().millisecondsSinceEpoch.toString();
    }
    if (_image != null) {
      profile = await FirebaseHelper.uploadImage(_image);
    } else {
      profile = _profileUrl;
    }

    print(_firstName);
    var user = User();
    user.userId = userId;
    user.firstName = _firstName;
    user.lastName = _lastName;
    user.phoneNumber = _phoneNumber;
    user.profilePicture = profile;

    var usr = await FirebaseHelper.createUser(user);

    if (usr != null) {
      // store user's details into preference
      MyPrefs.putString(Keys.USER_ID, userId);
      MyPrefs.putString(Keys.PHONE_NUMBER, _phoneNumber);
      MyPrefs.putString(Keys.FIRST_NAME, _firstName);
      MyPrefs.putString(Keys.LAST_NAME, _lastName);
      MyPrefs.putString(Keys.PROFILE, profile);
      MyPrefs.putBoolean(Keys.IS_USER_LOGIN, true);

      // move user to home screen
      MyNavigator.goToHome(context);
    } else {
      Snackbar.show(_scaffoldKey, App.error_something_wrong);
    }
  }

  Future _showImagePicker() async {
    print('showImagePicker');
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) =>
            AlertDialog(
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
        print("Selected File is EditProfile ${_image.path}");
      }
    }
  }
}
