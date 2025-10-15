import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 16,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.blue),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.shade600
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              radius: 16,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
