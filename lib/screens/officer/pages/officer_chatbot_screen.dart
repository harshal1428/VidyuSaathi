import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OfficerChatbotScreen extends StatefulWidget {
  const OfficerChatbotScreen({super.key});

  @override
  State<OfficerChatbotScreen> createState() => _OfficerChatbotScreenState();
}

class _OfficerChatbotScreenState extends State<OfficerChatbotScreen> {
  static const String _apiUrl = String.fromEnvironment('CHATBOT_API_URL');
  static const String _apiToken = String.fromEnvironment('CHATBOT_API_TOKEN');

  final TextEditingController _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    FocusScope.of(context).unfocus();
    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _sending = true;
    });

    if (_apiUrl.isEmpty || _apiToken.isEmpty) {
      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'Chatbot is not configured. Set CHATBOT_API_URL and CHATBOT_API_TOKEN in --dart-define.',
            isUser: false,
          ),
        );
        _sending = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({'message': text}),
      );

      final String reply;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          final dataReply = parsed['reply'] ?? parsed['response'] ?? parsed['message'];
          reply = (dataReply?.toString().trim().isNotEmpty ?? false)
              ? dataReply.toString().trim()
              : 'No response from assistant.';
        } else {
          reply = 'Unexpected chatbot response format.';
        }
      } else {
        reply = 'Chatbot unavailable (HTTP ${response.statusCode}). Please try again.';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'Unable to connect to chatbot right now. Please check network or backend.',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Officer Assistant')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Ask about complaint handling, SLA, escalation, or field resolution steps.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final align = m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                      final bubbleColor = m.isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200;
                      final textColor = m.isUser ? Colors.white : Colors.black87;
                      return Column(
                        crossAxisAlignment: align,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(m.text, style: TextStyle(color: textColor)),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}
