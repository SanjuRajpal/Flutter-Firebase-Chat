import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/beans/User.dart';
import 'package:flutter_app/beans/message.dart';
import 'package:flutter_app/beans/recent_message.dart';
import 'package:path/path.dart' as path;

class FirebaseHelper {
  static String dbName = "namasteDatabase";
  static String usersNode = "users";
  static String messageNode = "conversations";
  static String recentMessageNode = "recentConversations";

  static String generateChatId(String senderId, String receiverId) {
    var v1 = int.parse(senderId);
    var v2 = int.parse(receiverId);
    if (v1 > v2) {
      return receiverId + "_" + senderId;
    } else
      return senderId + "_" + receiverId;
  }

  static Future<User> createUser(User user) async {
    print('createUser');
    Map map = new Map();
    map['userId'] = user.userId;
    map['firstName'] = user.firstName.trim();
    map['lastName'] = user.lastName.trim();
    map['phoneNumber'] = user.phoneNumber;
    map['profilePicture'] = user.profilePicture;

    var ref = FirebaseDatabase.instance.reference().child(dbName);
    ref.child(usersNode).child(user.userId).set(map);
    return user;
  }

  static Future<User> checkIfUserExits(String phoneNumber) async {
    var ref = FirebaseDatabase.instance.reference().child(dbName);
    var result = await ref
        .child(usersNode)
        .orderByChild("phoneNumber")
        .equalTo(phoneNumber)
        .limitToFirst(1)
        .once();

    Map<dynamic, dynamic> map = result.value;

    if (map != null) {
      var element = map.entries.first.value;
      print(element.toString());
      User user = new User();
      user.userId = element['userId'];
      user.firstName = element['firstName'];
      user.lastName = element['lastName'];
      user.phoneNumber = element['phoneNumber'];
      return user;
    } else
      return null;
  }

  static Future<List<User>> doGetAllUsers(String id) async {
    var ref = FirebaseDatabase.instance.reference().child(dbName);
    var query = await ref.child(usersNode).once();

    Map<dynamic, dynamic> result = query.value;
    List<User> list = new List();

    if (result != null) {
      result.forEach((key, value) {
        if (id != value['userId']) {
          User user = new User();
          user.userId = value['userId'];
          user.firstName = value['firstName'];
          user.lastName = value['lastName'];
          user.phoneNumber = value['phoneNumber'];
          list.add(user);
        }
      });
    }
    return list;
  }

  static void doSendTextMessage(String chatId, Message message) {
    Map map = new Map();
    map['senderId'] = message.senderId;
    map['senderName'] = message.senderName;
    map['senderProfile'] = message.senderProfile;
    map['receiverId'] = message.receiverId;
    map['receiverProfile'] = message.receiverProfile;
    map['receiverName'] = message.receiverName;
    map['message'] = message.message;
    map['messageType'] = message.messageType;
    map['messageTimestamp'] = message.messageTimestamp;

    var ref = FirebaseDatabase.instance.reference().child(dbName);
    ref.child(messageNode).child(chatId).push().set(map);
    _doUpdateRecentConversations(chatId, message);
  }

  static void _doUpdateRecentConversations(String chatId, Message message) {
    var userId1 = chatId.split("_")[0];
    var userId2 = chatId.split("_")[1];

    RecentMessage recentMessage = RecentMessage();
    recentMessage.message = "";

    Map map = new Map();
    map['message'] = message.message;
    map['messageTimestamp'] = message.messageTimestamp;
    map['messageType'] = message.messageType;
    map['receiverId'] = message.receiverId;
    map['senderId'] = message.senderId;

    if (userId1 == message.senderId) {
      map['name'] = message.receiverName;
      map['profile'] = message.receiverProfile;

      var ref = FirebaseDatabase.instance.reference().child(dbName);
      ref.child(recentMessageNode).child(userId1).child(userId2).set(map);
    } else if (userId1 == message.receiverId) {
      map['name'] = message.senderName;
      map['profile'] = message.senderProfile;

      var ref = FirebaseDatabase.instance.reference().child(dbName);
      ref.child(recentMessageNode).child(userId1).child(userId2).set(map);
    }

    if (userId2 == message.senderId) {
      map['name'] = message.receiverName;
      map['profile'] = message.receiverProfile;

      var ref = FirebaseDatabase.instance.reference().child(dbName);
      ref.child(recentMessageNode).child(userId2).child(userId1).set(map);
    } else if (userId2 == message.receiverId) {
      map['name'] = message.senderName;
      map['profile'] = message.senderProfile;

      var ref = FirebaseDatabase.instance.reference().child(dbName);
      ref.child(recentMessageNode).child(userId2).child(userId1).set(map);
    }
  }

  static Future<List<Message>> doRetrieveMessages(String chatId) async {
    var ref = FirebaseDatabase.instance.reference().child(dbName);
    var query = await ref.child(messageNode).child(chatId).once();
    print(chatId);
    Map<dynamic, dynamic> result = query.value;
    List<Message> list = new List();

    if (result != null) {
      result.forEach((key, value) {
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

        list.add(msg);
      });
    }
    return list;
  }

  static DatabaseReference getConversationObserver(String chatId) {
    var ref = FirebaseDatabase.instance.reference().child(dbName);
    var query = ref.child(messageNode).child(chatId);
    return query;
  }

  static DatabaseReference getRecentConversationObserver(String userId) {
    var ref = FirebaseDatabase.instance.reference().child(dbName);
    var query = ref.child(recentMessageNode).child(userId);
    return query;
  }

  static Future<String> uploadImage(File image) async {
    var ref = FirebaseStorage.instance.ref().child("NamasteStorage");

    var fileName = new DateTime.now().millisecondsSinceEpoch.toString() +
        path.extension(image.path);
    var metadata = StorageMetadata(contentType: "image/jpg");
    var storage = ref.child("images/" + fileName);

    var uploadTask = storage.putFile(image, metadata);
    return await (await uploadTask.onComplete).ref.getDownloadURL();

//    uploadTask.events.listen((data) async {
////      var url = await storage.getDownloadURL();
////
////      user.profilePicture = url.toString();
////      print("URL: " + url.toString());
////    }).asFuture((e) {
////      print("Error: "+e.toString());
////      user.profilePicture = "";
////    });
  }

}
