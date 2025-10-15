class Message {
  final int? id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      content: map['content'] as String,
      isUser: map['isUser'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
  }
}
