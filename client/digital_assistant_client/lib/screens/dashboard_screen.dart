import 'package:flutter/material.dart';
import '../services/api_client.dart';

class DashboardScreen extends StatelessWidget {
  final ApiClient apiClient;

  const DashboardScreen({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Цифровой Ассистент',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Секция задач
            _sectionTitle('Задачи', Icons.task_alt),
            const SizedBox(height: 8),
            _buildTaskCard('Купить хлеб', '#срочно'),
            _buildTaskCard('Позвонить врачу', '#здоровье'),
            const SizedBox(height: 20),

            // Секция заметок
            _sectionTitle('Заметки', Icons.note),
            const SizedBox(height: 8),
            _buildNoteCard('Идея для стартапа'),
            _buildNoteCard('Рецепт борща'),
            const SizedBox(height: 20),

            // Секция календаря
            _sectionTitle('Календарь', Icons.calendar_today),
            const SizedBox(height: 8),
            _buildEventCard('Встреча с командой', '15:00'),
            const Spacer(),

            // Кнопка Умный ввод
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Умный ввод'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF1B6EF3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Заголовок секции с иконкой
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B6EF3), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Карточка задачи
  Widget _buildTaskCard(String title, String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.task_alt, color: Color(0xFF1B6EF3)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Chip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  // Карточка заметки
  Widget _buildNoteCard(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.note, color: Color(0xFF1B6EF3)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Карточка события
  Widget _buildEventCard(String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF1B6EF3)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}