import 'package:flutter/material.dart';

import '../controllers/chat_controller.dart';
import '../models/chatbot_models.dart';

class ChatbotScreen extends StatefulWidget {
  final ChatController controller;

  const ChatbotScreen({super.key, required this.controller});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _quickPrompts = [
    'Show top complaint categories this week.',
    'Which office has the highest pending complaints?',
    'Summarize escalations for my department.',
    'Show weather impact on electricity complaints.',
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final query = _textController.text;
    _textController.clear();
    await widget.controller.sendQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF0D47A1),
              child: Icon(Icons.smart_toy_outlined, size: 16, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('NagarSetu Assistant'),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F1FF), Color(0xFFF8FBFF)],
          ),
        ),
        child: Column(
          children: [
            _buildTopBanner(),
            _buildQuickPrompts(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  return _MessageBubble(message: m);
                },
              ),
            ),
            if (widget.controller.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                    SizedBox(width: 8),
                    Text('Assistant is thinking...'),
                  ],
                ),
              ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x220D47A1), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_moon_outlined, color: Color(0xFF1565C0)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Connected via secured token. Responses are scoped to your officer account.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return ActionChip(
            label: Text(prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
            labelStyle: const TextStyle(fontSize: 12),
            side: const BorderSide(color: Color(0xFF90CAF9)),
            backgroundColor: Colors.white,
            onPressed: widget.controller.isLoading
                ? null
                : () async {
                    await widget.controller.sendQuery(prompt);
                  },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _quickPrompts.length,
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFD7E3FF))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ask your civic query...',
                  filled: true,
                  fillColor: const Color(0xFFF5F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                onPressed: widget.controller.isLoading ? null : _send,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x140D47A1), blurRadius: 10, offset: Offset(0, 2)),
          ],
          border: isUser ? null : Border.all(color: const Color(0xFFE3EEFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1F2937),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(message.time),
              style: TextStyle(
                fontSize: 11,
                color: isUser ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
