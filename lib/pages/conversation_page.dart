import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/beans/message.dart';
import 'package:flutter_app/enums/enums.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/utils/FirebaseHelper.dart';
import 'package:flutter_app/utils/MyPrefs.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:flutter_app/widgets/left_right_align.dart';
import 'package:intl/intl.dart';

class Conversations extends StatefulWidget {
  final User user;

  Conversations({Key key, @required this.user}) : super(key: key);

  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = new ScrollController();

  bool _showLoading = true;
  User _user;
  String _textMessage;
  String _senderId;
  String _senderName;
  String _receiverId;
  String _receiverName = "";
  String _chatId;
  List<Message> _messages = new List();
  var formatter = new DateFormat('hh:mm:ss');

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    init();
  }

  void init() async {
    _senderId = await MyPrefs.getString(Keys.USER_ID);
    var fName = await MyPrefs.getString(Keys.FIRST_NAME);
    var lName = await MyPrefs.getString(Keys.LAST_NAME);

    setState(() {
      _senderName = fName + " " + lName;
      _receiverId = _user.userId;
      _receiverName = _user.firstName + " " + _user.lastName;
    });
    _chatId = FirebaseHelper.generateChatId(_senderId, _receiverId);
    _addMessageCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: Utils.getAppBar(context, _receiverName),
      backgroundColor: App.primaryColorLight,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                color: App.primaryColorLight,
                child: _getList(),
              ),
            ),
            _getInputView()
          ],
        ),
      ),
    );
  }

  Widget _getList() {
    return ListView.builder(
      padding: EdgeInsets.all(15),
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          var message = _messages[index];
          if (message.senderId == _senderId)
            return _getSenderView(message);
          else
            return _getReceiverView(message);
        },
        itemCount: _messages == null ? 0 : _messages.length);
  }

  Widget _getSenderView(Message message) {
    return LeftRightAlign(
      right: Padding(
        padding: EdgeInsets.only(left: 80),
        child: Card(
          color: App.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  message.message,
                  style: TextStyle(fontSize: 14, color: App.black),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    formatter.format(DateTime.fromMillisecondsSinceEpoch(
                        message.messageTimestamp)),
                    style: TextStyle(fontSize: 8, color: App.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      left: Container(),
    );
  }

  Widget _getReceiverView(Message message) {
    return LeftRightAlign(
      right: Container(),
      left: Padding(
        padding: EdgeInsets.only(right: 80),
        child: Card(
          color: App.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.message,
                  style: TextStyle(fontSize: 14, color: App.black),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    formatter.format(DateTime.fromMillisecondsSinceEpoch(
                        message.messageTimestamp)),
                    style: TextStyle(fontSize: 8, color: App.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getInputView() {
    return Padding(
      padding: EdgeInsets.only(left: 15,right: 15),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Card(
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              color: App.white,
              child: Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: TextFormField(
                  controller: _controller,
                  style: TextStyle(fontSize: 16, color: App.black),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (value) {
                    _textMessage = value;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16, color: App.black),
                      hintText: 'Type a message',
                      counterText: "",
                      errorStyle: TextStyle(fontSize: 12, color: App.black),
                      hoverColor: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: GestureDetector(
              onTap: _sendMessage,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                color: App.white,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_textMessage.length != 0) {
      var timeStamp = new DateTime.now().millisecondsSinceEpoch;

      var msg = Message();
      msg.senderId = _senderId;
      msg.senderName = _senderName;
      msg.senderProfile = "";
      msg.receiverId = _receiverId;
      msg.receiverName = _receiverName;
      msg.receiverProfile = "";
      msg.message = _textMessage;
      msg.messageType = "text";
      msg.messageTimestamp = timeStamp;

      FirebaseHelper.doSendTextMessage(_chatId, msg);
      setState(() {
        _controller.clear();
        _textMessage = "";
      });
    }
  }

  void _addMessageCallback() {
    var query = FirebaseHelper.getConversationObserver(_chatId);
    query.onChildAdded.listen((event) {
      if (mounted) {
        var value = event.snapshot.value;
        if (value != null) {
          Message msg = Message();
          msg.senderId = value['senderId'];
          msg.senderProfile = value['senderProfile'];
          msg.senderName = value['senderName'];
          msg.receiverProfile = value['receiverProfile'];
          msg.receiverName = value['receiverName'];
          msg.receiverId = value['receiverId'];
          msg.message = value['message'];
          msg.messageTimestamp = value['messageTimestamp'];
          msg.messageType = value['messageType'];
          msg.media = value['media'];
          if (mounted) {
            setState(() {
              _messages.add(msg);
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent +
                      _scrollController.offset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn);
            });
          }
        }
      }
    });
  }
}
