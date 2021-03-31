class Message {
  String _senderId;
  String _senderName;
  String _senderProfile;
  String _receiverId;
  String _receiverProfile;
  String _receiverName;
  String _message;
  String _messageType;
  String _media;
  int _messageTimestamp;


  String get senderId => _senderId;

  set senderId(String value) {
    _senderId = value;
  }

  String get senderName => _senderName;

  int get messageTimestamp => _messageTimestamp;

  set messageTimestamp(int value) {
    _messageTimestamp = value;
  }

  String get media => _media;

  set media(String value) {
    _media = value;
  }

  String get messageType => _messageType;

  set messageType(String value) {
    _messageType = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get receiverName => _receiverName;

  set receiverName(String value) {
    _receiverName = value;
  }

  String get receiverProfile => _receiverProfile;

  set receiverProfile(String value) {
    _receiverProfile = value;
  }

  String get receiverId => _receiverId;

  set receiverId(String value) {
    _receiverId = value;
  }

  String get senderProfile => _senderProfile;

  set senderProfile(String value) {
    _senderProfile = value;
  }

  set senderName(String value) {
    _senderName = value;
  }

}
