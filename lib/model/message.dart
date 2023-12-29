import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class MessageService {
  static Future<void> sendMessage(Message message, String channelId) async {
    await _firestore
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .add({
      'text': message.text,
      'sender': message.sender,
      'timestamp': message.timestamp,
    });
  }

  static Stream<List<Message>> getMessages(String channelId) {
    return _firestore
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Message(
                text: data['text'],
                sender: data['sender'],
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }).toList());
  }
}
