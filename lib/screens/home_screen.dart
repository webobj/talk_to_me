import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';
import '../services/conversation_service.dart';
import '../widgets/message_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _handleVoiceInput() async {
    final voiceService = Provider.of<VoiceService>(context, listen: false);
    final conversationService = Provider.of<ConversationService>(context, listen: false);

    await voiceService.startListening(
      onResult: (recognizedText) async {
        if (recognizedText.isNotEmpty) {
          // Process the user input and get AI response
          await conversationService.processUserInput(recognizedText);

          // Speak the AI response
          if (conversationService.messages.isNotEmpty) {
            final lastMessage = conversationService.messages.last;
            if (!lastMessage.isUser) {
              await voiceService.speak(lastMessage.content);
            }
          }

          _scrollToBottom();
        }
      },
    );
  }

  Future<void> _handleTextInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    final conversationService = Provider.of<ConversationService>(context, listen: false);
    final voiceService = Provider.of<VoiceService>(context, listen: false);

    // Process the user input and get AI response
    await conversationService.processUserInput(text);

    // Speak the AI response
    if (conversationService.messages.isNotEmpty) {
      final lastMessage = conversationService.messages.last;
      if (!lastMessage.isUser) {
        await voiceService.speak(lastMessage.content);
      }
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk To Me'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Conversation'),
                  content: const Text('Are you sure you want to clear all messages?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await Provider.of<ConversationService>(context, listen: false)
                    .clearConversation();
              }
            },
          ),
        ],
      ),
      body: Consumer2<VoiceService, ConversationService>(
        builder: (context, voiceService, conversationService, child) {
          return Column(
            children: [
              // Status indicator
              if (voiceService.isListening || voiceService.isSpeaking || conversationService.isLoading)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        voiceService.isListening
                            ? 'Listening...'
                            : voiceService.isSpeaking
                                ? 'Speaking...'
                                : 'Processing...',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

              // Messages list
              Expanded(
                child: conversationService.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_none,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Type a message or tap the microphone to start',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: conversationService.messages.length,
                        itemBuilder: (context, index) {
                          final message = conversationService.messages[index];
                          return MessageBubble(message: message);
                        },
                      ),
              ),

              // Text and Voice input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _handleTextInput(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _handleTextInput,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: voiceService.isListening
                          ? () => voiceService.stopListening()
                          : _handleVoiceInput,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: voiceService.isListening
                              ? Colors.red
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (voiceService.isListening
                                      ? Colors.red
                                      : Colors.grey.shade400)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          voiceService.isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
