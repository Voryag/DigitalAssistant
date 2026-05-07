import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ChatScreen extends StatefulWidget {
  final ApiClient apiClient;

  const ChatScreen({super.key, required this.apiClient});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': DateTime.now()});
      _loading = true;
    });
    _messageController.clear();

    try {
      // Отправляем в AI
      final aiResult = await widget.apiClient.parseAI(text);

      String reply = '';

      if (aiResult != null) {
        final intent = aiResult['intent'] ?? 'note';
        final tags = List<String>.from(aiResult['tags'] ?? []);

        if (intent == 'task') {
          await widget.apiClient.createTask(
            title: text,
            aiTags: tags,
          );
          reply = '✅ Создал задачу «$text»${tags.isNotEmpty ? '\n📌 Теги: ${tags.join(", ")}' : ''}';
        } else if (intent == 'note') {
          await widget.apiClient.createNote(text, '', tags);
          reply = '📝 Сохранил заметку${tags.isNotEmpty ? '\n📌 Теги: ${tags.join(", ")}' : ''}';
        } else if (intent == 'calendar') {
          reply = '📅 Добавил в календарь: $text';
        } else {
          reply = '💡 $text';
        }
      } else {
        reply = '⚠️ Не удалось обработать запрос';
      }

      setState(() {
        _messages.add({'role': 'assistant', 'text': reply, 'time': DateTime.now()});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': '❌ Ошибка: $e', 'time': DateTime.now()});
        _loading = false;
      });
    }

    // Прокрутка вниз
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Digital Helper', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
        actions: [
          IconButton(
            icon: const Icon(Icons.task),
            onPressed: () {
              // Переход к списку задач (добавим позже)
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const _LoginRedirect()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[i]);
              },
            ),
          ),
          // Поле ввода
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B6EF3) : const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'],
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg['time']),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: 60,
          height: 30,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF0A1628),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Напишите, что нужно сделать...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1B2838),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1B6EF3),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Заглушка для редиректа на логин
class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}