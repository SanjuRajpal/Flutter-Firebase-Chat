import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/beans/recent_message.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _userId;
  List<RecentMessage> _messages = new List();
  var _formatter = new DateFormat('hh:mm a');

  @override
  void initState() {
    print("initState");
    super.initState();
    _init();
  }

  void _init() async {
    _userId = await MyPrefs.getString(Keys.USER_ID);
    _recentChatObserver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        actions: <Widget>[_optionsMenu()],
        title: Text(App.name),
      ),
      body: Container(
        color: App.primaryColorLight,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return _getView(_messages[index]);
              },
              itemCount: _messages == null ? 0 : _messages.length),
        ),
      ),
    );
  }

  Widget _optionsMenu() {
    return PopupMenuButton<Options>(
        onSelected: (Options result) {
          setState(() {
            switch (result) {
              case Options.SETTING:
                MyNavigator.goToSettings(context);
                break;
              case Options.NEW_CHAT:
                MyNavigator.goToNewChat(context);
                break;
            }
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
              const PopupMenuItem<Options>(
                value: Options.NEW_CHAT,
                child: Text(
                  App.new_chat,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: App.black),
                ),
              ),
              const PopupMenuItem<Options>(
                value: Options.SETTING,
                child: Text(
                  App.settings,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: App.black),
                ),
              )
            ]);
  }

  Widget _getView(RecentMessage message) {
    return Card(
      color: App.white,
      child: ListTile(
        onTap: () {
          _handleClick(message);
        },
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
        title: Text(message.name,
            style: TextStyle(fontSize: 16, color: App.black)),
        trailing: Text(
          _formatter.format(
              DateTime.fromMillisecondsSinceEpoch(message.messageTimestamp)),
          style: TextStyle(fontSize: 8, color: App.black),
        ),
        subtitle: Text(message.message,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: App.black)),
      ),
    );
  }

  void _handleClick(RecentMessage message) {
    var id;
    if (_userId == message.senderId)
      id = message.receiverId;
    else
      id = message.senderId;

    var fName = message.name.split(" ")[0];
    var lName = message.name.split(" ")[1];

    var user = User();
    user.userId = id;
    user.firstName = fName;
    user.lastName = lName;
    user.phoneNumber = "";
    user.profilePicture = message.profile;

    MyNavigator.goToConversations(context, user);
  }

  void _recentChatObserver() {
    var query = FirebaseHelper.getRecentConversationObserver(_userId);
    query.onChildAdded.listen((event) {
      print('onChildAdded ' + mounted.toString());
      if (mounted) {
        var value = event.snapshot.value;
        if (value != null) {
          RecentMessage msg = new RecentMessage();
          msg.senderId = value['senderId'];
          msg.receiverId = value['receiverId'];
          msg.messageType = value['messageType'];
          msg.profile = value['profile'];
          msg.name = value['name'];
          msg.message = value['message'];
          msg.messageTimestamp = value['messageTimestamp'];

          if (mounted) {
            setState(() {
              _messages.add(msg);
            });
          }
        }
      }
    });

    query.onChildChanged.listen((event) {
      print('onChildChanged ' + mounted.toString());
      if (mounted) {
        var value = event.snapshot.value;
        print(value.toString());
        if (value != null) {
          RecentMessage msg = new RecentMessage();
          msg.senderId = value['senderId'];
          msg.receiverId = value['receiverId'];
          msg.messageType = value['messageType'];
          msg.profile = value['profile'];
          msg.name = value['name'];
          msg.message = value['message'];
          msg.messageTimestamp = value['messageTimestamp'];

          _messages.forEach((data) {
            if (msg.senderId == data.senderId &&
                    msg.receiverId == data.receiverId ||
                (msg.senderId == data.receiverId) &&
                    (msg.receiverId == data.senderId)) {
              _messages.remove(data);
              if (mounted)
                setState(() {
                  _messages.add(msg);
                });
            }
          });
        }
      }
    });
  }
}
