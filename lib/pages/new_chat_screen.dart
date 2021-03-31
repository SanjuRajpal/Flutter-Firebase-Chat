import 'package:flutter/material.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/utils/Utils.dart';

class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  List<User> _list;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    _retrieveAllUsers();
  }

  void _retrieveAllUsers() async {
    var id = await MyPrefs.getString(Keys.USER_ID);
    var list = await FirebaseHelper.doGetAllUsers(id);
    setState(() {
      _list = list;
      _showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: Utils.getAppBar(context, App.new_chat),
      backgroundColor: App.primaryColorLight,
      body: _showLoading
          ? LinearProgressIndicator()
          : Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5), child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: GestureDetector(
                        onTap: () => MyNavigator.goToConversations(context, _list[index]),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/ic_user_default.png',
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                              _list[index].firstName + " " + _list[index].lastName,
                              style: TextStyle(fontSize: 16, color: App.black)),
                          subtitle: Text(_list[index].phoneNumber,
                              style: TextStyle(fontSize: 12, color: App.black)),
                        ),
                      ),
                    );
                  },
                  itemCount: _list == null ? 0 : _list.length)),
            ),
    );
  }

}
