import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';
import 'database_helper.dart';

class ConversationService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  ConversationService() {
    loadMessages();
  }

  Future<void> loadMessages() async {
    _messages = await _dbHelper.getAllMessages();
    notifyListeners();
  }

  Future<void> addUserMessage(String content) async {
    final message = Message(content: content, isUser: true);
    await _dbHelper.insertMessage(message);
    await loadMessages();
  }

  Future<void> addAssistantMessage(String content) async {
    final message = Message(content: content, isUser: false);
    await _dbHelper.insertMessage(message);
    await loadMessages();
  }

  Future<String> getAIResponse(String userMessage) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get conversation context (last 10 messages)
      final recentMessages = await _dbHelper.getRecentMessages(10);

      // Prepare messages for API
      final apiMessages = recentMessages.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        };
      }).toList();

      // Add the new user message
      apiMessages.add({
        'role': 'user',
        'content': userMessage,
      });

      // Call OpenAI API (you can replace with any LLM provider)
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        return 'Please add your OPENAI_API_KEY to the .env file';
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': apiMessages,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        return aiResponse.trim();
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error communicating with AI: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processUserInput(String input) async {
    // Save user message
    await addUserMessage(input);

    // Get AI response
    final response = await getAIResponse(input);

    // Save AI response
    await addAssistantMessage(response);
  }

  Future<void> clearConversation() async {
    await _dbHelper.clearAllMessages();
    await loadMessages();
  }
}
