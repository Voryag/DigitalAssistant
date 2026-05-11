import 'package:flutter/material.dart';
import '../services/api_client.dart';

class StatsScreen extends StatefulWidget {
  final ApiClient apiClient;

  const StatsScreen({super.key, required this.apiClient});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await widget.apiClient.getDashboardStats();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalTasks = _stats!['total_tasks'] ?? 0;
    final totalNotes = _stats!['total_notes'] ?? 0;
    final totalEvents = _stats!['total_events'] ?? 0;
    final todayEvents = _stats!['today_events'] ?? 0;
    final easy = _stats!['tasks_easy'] ?? 0;
    final medium = _stats!['tasks_medium'] ?? 0;
    final hard = _stats!['tasks_hard'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Дашборд', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточки статистики
            Row(
              children: [
                _buildStatCard('Задач', totalTasks.toString(), Icons.task_alt, const Color(0xFF1B6EF3)),
                const SizedBox(width: 12),
                _buildStatCard('Заметок', totalNotes.toString(), Icons.note, Colors.greenAccent),
                const SizedBox(width: 12),
                _buildStatCard('Событий', totalEvents.toString(), Icons.calendar_today, Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 16),

            // События сегодня
            _buildHighlightCard('📅 Сегодня', '$todayEvents событий', const Color(0xFF1B2838)),
            const SizedBox(height: 24),

            // Распределение задач по приоритетам
            const Text('Задачи по приоритетам', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPriorityBar('Easy', easy, totalTasks, Colors.greenAccent),
            const SizedBox(height: 8),
            _buildPriorityBar('Medium', medium, totalTasks, Colors.orangeAccent),
            const SizedBox(height: 8),
            _buildPriorityBar('Hard', hard, totalTasks, Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String emoji, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text('$emoji  $text', style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 14)),
            Text('$count', style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(width: double.infinity, height: 8, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
      ],
    );
  }
}