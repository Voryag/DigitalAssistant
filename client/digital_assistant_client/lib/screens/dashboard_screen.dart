import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'map_screen.dart';

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
      CalendarScreen(apiClient: widget.apiClient),
    ];
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMoreItem(Icons.table_chart, 'Таблицы', () => Navigator.pop(ctx)),
            _buildMoreItem(Icons.map, 'Карты', () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MapsScreen(apiClient: widget.apiClient)),
                );
              }),
            _buildMoreItem(Icons.bar_chart, 'Графики', () => Navigator.pop(ctx)),
            _buildMoreItem(
              Icons.analytics, 'Статистика', () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StatsScreen(apiClient: widget.apiClient)),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B6EF3)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  void _showSearch() {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (ctx, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1B2838),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск по заметкам, задачам...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1B6EF3)),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setSheetState(() {}),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: searchController.text.length >= 2
                        ? widget.apiClient.search(searchController.text)
                        : Future.value({"results": []}),
                    builder: (_, snapshot) {
                      if (searchController.text.length < 2) {
                        return const Center(
                          child: Text(
                            'Введите минимум 2 символа',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final results = snapshot.data?['results'] as List<dynamic>? ?? [];

                      if (results.isEmpty) {
                        return const Center(
                          child: Text(
                            'Ничего не найдено',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final item = results[i];
                          final typeIcons = {
                            'note': Icons.note,
                            'task': Icons.task_alt,
                            'event': Icons.calendar_today,
                          };
                          final typeLabels = {
                            'note': 'Заметка',
                            'task': 'Задача',
                            'event': 'Событие',
                          };

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Icon(
                                typeIcons[item['type']] ?? Icons.search,
                                color: const Color(0xFF1B6EF3),
                              ),
                              title: Text(
                                item['title'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    typeLabels[item['type']] ?? item['type'],
                                    style: const TextStyle(color: Color(0xFF1B6EF3), fontSize: 12),
                                  ),
                                  if (item['snippet'] != null && item['snippet'].toString().isNotEmpty)
                                    Text(
                                      item['snippet'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex < 4 ? _currentIndex : 4,
        onTap: (i) {
          if (i < 4) {
            setState(() => _currentIndex = i);
          } else {
            _showMoreMenu();
          }
        },
        backgroundColor: const Color(0xFF0A1628),
        selectedItemColor: const Color(0xFF1B6EF3),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Заметки'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Календарь'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Ещё'),
        ],
      ),
    );
  }
}

// ==================== ЧАТ ====================
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
      final title = aiResult['title'] ?? text;
      final content = aiResult['content'] ?? '';
      final project = aiResult['project'] ?? '';
      final tags = aiResult['tags'] ?? '';
      final priority = aiResult['priority'] ?? 'medium';
      final dueDate = aiResult['due_date'] ?? '';

      if (intent == 'task') {
        await widget.apiClient.createTask(
          title: title,
          content: content,
          project: project,
          tags: tags,
          priority: priority,
          dueDate: dueDate.isNotEmpty ? dueDate : null,
        );
        reply = '✅ Задача создана: "$title"'
            '${project.isNotEmpty ? '\n📁 Проект: $project' : ''}'
            '${tags.isNotEmpty ? '\n🏷️ $tags' : ''}'
            '${dueDate.isNotEmpty ? '\n📅 До: $dueDate' : ''}';
      } else if (intent == 'note') {
        await widget.apiClient.createNote(title, content, []);
        reply = '📝 Заметка сохранена: "$title"';
      } else if (intent == 'calendar') {
        reply = '📅 Добавил в календарь: "$title"';
      } else {
        reply = '💡 "$title"';
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

// ==================== ЗАМЕТКИ ====================
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6EF3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Создать', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
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

// ==================== ЗАДАЧИ ====================
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
    final tagsC = TextEditingController();
    DateTime? dueDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1B2838),
          title: const Text('Новая задача', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
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
                  controller: descC,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    labelStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0D1B2A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: projectC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Проект',
                    labelStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0D1B2A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Метка (#срочно)',
                    labelStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0D1B2A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dueDate == null
                        ? 'Дата завершения (не выбрана)'
                        : 'Дата завершения: ${dueDate!.day}.${dueDate!.month}.${dueDate!.year}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Color(0xFF1B6EF3)),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF1B6EF3),
                            surface: Color(0xFF1B2838),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (d != null) setDialogState(() => dueDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Отмена', style: TextStyle(color: Colors.white70, fontSize: 15)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6EF3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Создать', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await widget.apiClient.createTask(
        title: titleC.text.trim(),
        content: descC.text.trim(),
        project: projectC.text.trim(),
        tags: tagsC.text.trim(),
        dueDate: dueDate?.toIso8601String(),
      );
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await widget.apiClient.deleteTask(id);
    _load();
  }

  Widget _buildTaskCard(dynamic task) {
    final priority = task['priority'] ?? 'medium';
    final colors = {
      'easy': Colors.greenAccent,
      'medium': Colors.orangeAccent,
      'hard': Colors.redAccent,
    };
    final icons = {
      'easy': Icons.sentiment_satisfied,
      'medium': Icons.sentiment_neutral,
      'hard': Icons.sentiment_dissatisfied,
    };
    final aiTags = task['ai_tags'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1B2838),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.launch, color: Color(0xFFFC6D26), size: 20),
                  tooltip: 'Отправить в GitLab',
                  onPressed: () async {
                    final result = await widget.apiClient.exportToGitLab(task['id'], task['title']);
                    if (result != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Задача в GitLab: ${result['gitlab_url']}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Ошибка GitLab'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            ),
            if (task['project'] != null && task['project'].toString().isNotEmpty)
              Text('Проект: ${task['project']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            if (task['tags'] != null && task['tags'].toString().isNotEmpty)
              Text(task['tags'], style: const TextStyle(color: Color(0xFF1B6EF3), fontSize: 13)),
            if (aiTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: aiTags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6EF3).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag.toString(),
                      style: const TextStyle(color: Color(0xFF1B6EF3), fontSize: 11),
                    ),
                  )).toList(),
                ),
              ),
            if (task['content'] != null && task['content'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(task['content'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
              ),
            Row(
              children: [
                if (task['start_date'] != null)
                  Text('С: ${task['start_date'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                if (task['start_date'] != null && task['due_date'] != null)
                  const Text('  ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                if (task['due_date'] != null)
                  Text('До: ${task['due_date'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icons[priority] ?? Icons.help, color: colors[priority], size: 18),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: priority,
                      dropdownColor: const Color(0xFF1B2838),
                      style: TextStyle(color: colors[priority], fontSize: 13),
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'easy', child: Text('Easy', style: TextStyle(color: Colors.greenAccent))),
                        DropdownMenuItem(value: 'medium', child: Text('Medium', style: TextStyle(color: Colors.orangeAccent))),
                        DropdownMenuItem(value: 'hard', child: Text('Hard', style: TextStyle(color: Colors.redAccent))),
                      ],
                      onChanged: (v) async {
                        await widget.apiClient.updateTaskPriority(task['id'], v!);
                        _load();
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () => _delete(task['id']),
                ),
              ],
            ),
          ],
        ),
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
                  itemBuilder: (_, i) => _buildTaskCard(_tasks[i]),
                ),
    );
  }
}

// ==================== ЗАГЛУШКА ====================
class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();
  @override
  Widget build(BuildContext context) => const SizedBox();
}