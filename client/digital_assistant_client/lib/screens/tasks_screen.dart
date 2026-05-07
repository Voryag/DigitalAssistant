import 'package:flutter/material.dart';
import '../services/api_client.dart';

class TasksScreen extends StatefulWidget {
  final ApiClient apiClient;

  const TasksScreen({super.key, required this.apiClient});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await widget.apiClient.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _createTask() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final projectController = TextEditingController();
    final labelController = TextEditingController();
    String priority = 'medium';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1B2838),
          title: const Text('Новая задача', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(titleController, 'Заголовок'),
                const SizedBox(height: 12),
                _buildField(descController, 'Описание', maxLines: 3),
                const SizedBox(height: 12),
                _buildField(projectController, 'Проект'),
                const SizedBox(height: 12),
                _buildField(labelController, 'Метка (#срочно)'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  dropdownColor: const Color(0xFF1B2838),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Приоритет',
                    labelStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0D1B2A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Низкий')),
                    DropdownMenuItem(value: 'medium', child: Text('Средний')),
                    DropdownMenuItem(value: 'high', child: Text('Высокий')),
                  ],
                  onChanged: (v) => setDialogState(() => priority = v!),
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
                  child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6EF3),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Создать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await widget.apiClient.createTask(
        title: titleController.text.trim(),
        content: descController.text.trim(),
        project: projectController.text.trim(),
        priority: priority,
      );
      _loadTasks();
    }
  }

  Future<void> _deleteTask(int id) async {
    await widget.apiClient.deleteTask(id);
    _loadTasks();
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        floatingLabelStyle: const TextStyle(color: Color(0xFF1B6EF3)),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B6EF3),
        onPressed: _createTask,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Нет задач', style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (_, i) {
                    final task = _tasks[i];
                    return _buildTaskCard(task);
                  },
                ),
    );
  }

  Widget _buildTaskCard(dynamic task) {
    final priority = task['priority'] ?? 'medium';
    final colors = {
      'high': Colors.redAccent,
      'medium': Colors.orangeAccent,
      'low': Colors.greenAccent,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.task_alt, color: colors[priority] ?? const Color(0xFF1B6EF3)),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task['due_date'] != null)
              Text(task['due_date'].toString().substring(0, 10), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteTask(task['id']),
            ),
          ],
        ),
      ),
    );
  }
}