import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:digital_assistant_client/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiClient apiClient;

  const DashboardScreen({super.key, required this.apiClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await widget.apiClient.getNotes();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _createNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Новая заметка', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Заголовок',
                labelStyle: const TextStyle(color: Colors.white54),
                floatingLabelStyle: const TextStyle(color: Color(0xFF1B6EF3)),
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1B6EF3), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Текст',
                labelStyle: const TextStyle(color: Colors.white54),
                floatingLabelStyle: const TextStyle(color: Color(0xFF1B6EF3)),
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1B6EF3), width: 2),
                ),
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
    );

    if (result == true) {
      await widget.apiClient.createNote(
        titleController.text.trim(),
        contentController.text.trim(),
        [],
      );
      _loadNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    await widget.apiClient.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Цифровой Ассистент', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Заметки', Icons.note),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF1B6EF3), size: 30),
                  onPressed: _createNote,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _notes.isEmpty
                      ? const Center(
                          child: Text('Нет заметок', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (_, i) {
                            final note = _notes[i];
                            return _buildNoteCard(
                              note['title'] ?? '',
                              note['content'] ?? '',
                              note['id'] ?? 0,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B6EF3), size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildNoteCard(String title, String content, int id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.note, color: Color(0xFF1B6EF3)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: content.isEmpty
            ? null
            : Text(content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _deleteNote(id),
        ),
      ),
    );
  }
}