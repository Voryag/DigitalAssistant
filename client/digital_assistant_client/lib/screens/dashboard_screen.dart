import 'package:flutter/material.dart';
import '../services/api_client.dart';

class DashboardScreen extends StatefulWidget {
  final ApiClient apiClient;

  const DashboardScreen({super.key, required this.apiClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _ChatTab(apiClient: widget.apiClient),
      _NotesTab(apiClient: widget.apiClient),
      _TasksTab(apiClient: widget.apiClient),
    ];
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF0A1628),
        selectedItemColor: const Color(0xFF1B6EF3),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Заметки'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Задачи'),
        ],
      ),
    );
  }
}

// ==================== ВКЛАДКА ЧАТ ====================
class _ChatTab extends StatefulWidget {
  final ApiClient apiClient;
  const _ChatTab({required this.apiClient});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _addMessage('assistant', 'Привет! Напиши, что нужно сделать, и я создам задачу или заметку.');
  }

  void _addMessage(String role, String text) {
    setState(() {
      _messages.add({'role': role, 'text': text, 'time': DateTime.now()});
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage('user', text);
    _messageController.clear();
    setState(() => _loading = true);

    try {
      final aiResult = await widget.apiClient.parseAI(text);
      String reply;

      if (aiResult != null) {
        final intent = aiResult['intent'] ?? 'note';
        final tags = List<String>.from(aiResult['tags'] ?? []);

        if (intent == 'task') {
          await widget.apiClient.createTask(title: text, tags: tags);
          reply = '✅ Задача создана${tags.isNotEmpty ? '\n📌 Теги: ${tags.join(", ")}' : ''}';
        } else if (intent == 'note') {
          await widget.apiClient.createNote(text, '', tags);
          reply = '📝 Заметка сохранена${tags.isNotEmpty ? '\n📌 Теги: ${tags.join(", ")}' : ''}';
        } else if (intent == 'calendar') {
          reply = '📅 Добавил в календарь: $text';
        } else {
          reply = '💡 $text';
        }
      } else {
        reply = '⚠️ Не удалось обработать запрос';
      }

      _addMessage('assistant', reply);
    } catch (e) {
      _addMessage('assistant', '❌ Ошибка соединения');
    }

    setState(() => _loading = false);
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (_loading && i == _messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                    ),
                  ),
                );
              }
              final msg = _messages[i];
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
                      Text(msg['text'], style: const TextStyle(color: Colors.white, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        '${msg['time'].hour}:${msg['time'].minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
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
        ),
      ],
    );
  }
}

// ==================== ВКЛАДКА ЗАМЕТКИ ====================
class _NotesTab extends StatefulWidget {
  final ApiClient apiClient;
  const _NotesTab({required this.apiClient});

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  List<dynamic> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await widget.apiClient.getNotes();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final titleC = TextEditingController();
    final contentC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Новая заметка', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF0D1B2A),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentC,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Текст',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF0D1B2A),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B6EF3)),
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.apiClient.createNote(titleC.text.trim(), contentC.text.trim(), []);
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await widget.apiClient.deleteNote(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B6EF3),
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('Нет заметок', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (_, i) {
                    final note = _notes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.note, color: Color(0xFF1B6EF3)),
                        title: Text(note['title'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: note['content'] != null && note['content'].toString().isNotEmpty
                            ? Text(note['content'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54))
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _delete(note['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== ВКЛАДКА ЗАДАЧИ ====================
class _TasksTab extends StatefulWidget {
  final ApiClient apiClient;
  const _TasksTab({required this.apiClient});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  List<dynamic> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await widget.apiClient.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final projectC = TextEditingController();
    final labelC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Новая задача', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(titleC, 'Заголовок'),
              const SizedBox(height: 12),
              _field(descC, 'Описание', maxLines: 3),
              const SizedBox(height: 12),
              _field(projectC, 'Проект'),
              const SizedBox(height: 12),
              _field(labelC, 'Метка'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B6EF3)),
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.apiClient.createTask(
        title: titleC.text.trim(),
        description: descC.text.trim(),
        project: projectC.text.trim(),
        label: labelC.text.trim(),
      );
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await widget.apiClient.deleteTask(id);
    _load();
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B6EF3),
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Нет задач', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (_, i) {
                    final task = _tasks[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.task_alt, color: Color(0xFF1B6EF3)),
                        title: Text(task['title'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task['project'] != null && task['project'].toString().isNotEmpty)
                              Text('Проект: ${task['project']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            if (task['label'] != null && task['label'].toString().isNotEmpty)
                              Text('Метка: ${task['label']}', style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _delete(task['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== ЗАГЛУШКА РЕДИРЕКТА ====================
class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();
  @override
  Widget build(BuildContext context) => const SizedBox();
}