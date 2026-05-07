import 'package:flutter/material.dart';
import '../services/api_client.dart';

class CalendarScreen extends StatefulWidget {
  final ApiClient apiClient;

  const CalendarScreen({super.key, required this.apiClient});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<dynamic> _events = [];
  bool _loading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await widget.apiClient.getEvents();
    if (!mounted) return;
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  Future<void> _createEvent() async {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1B2838),
          title: const Text('Новое событие', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Название',
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
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    labelStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0D1B2A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Начало', style: TextStyle(color: Colors.white54)),
                  trailing: Text(
                    '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: startTime,
                    );
                    if (t != null) setDialogState(() => startTime = t);
                  },
                ),
                ListTile(
                  title: const Text('Конец', style: TextStyle(color: Colors.white54)),
                  trailing: Text(
                    '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: endTime,
                    );
                    if (t != null) setDialogState(() => endTime = t);
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

    if (ok == true && titleC.text.trim().isNotEmpty) {
      final startDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        startTime.hour, startTime.minute,
      );
      final endDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        endTime.hour, endTime.minute,
      );

      await widget.apiClient.createEvent(
        title: titleC.text.trim(),
        content: descC.text.trim(),
        startTime: startDt.toIso8601String(),
        endTime: endDt.toIso8601String(),
      );
      _loadEvents();
    }
  }

  Future<void> _deleteEvent(int id) async {
    await widget.apiClient.deleteEvent(id);
    _loadEvents();
  }

  List<dynamic> _eventsForSelectedDate() {
    return _events.where((e) {
      final start = DateTime.parse(e['start_time']);
      return start.year == _selectedDate.year &&
          start.month == _selectedDate.month &&
          start.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _eventsForSelectedDate();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Календарь', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B6EF3),
        onPressed: _createEvent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                ),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
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
                    if (d != null) setState(() => _selectedDate = d);
                  },
                  child: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : dayEvents.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет событий на этот день',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dayEvents.length,
                        itemBuilder: (_, i) {
                          final event = dayEvents[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today, color: Color(0xFF1B6EF3)),
                              title: Text(event['title'] ?? '', style: const TextStyle(color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event['content'] != null && event['content'].toString().isNotEmpty)
                                    Text(event['content'], style: const TextStyle(color: Colors.white54)),
                                  Text(
                                    '${DateTime.parse(event['start_time']).hour}:${DateTime.parse(event['start_time']).minute.toString().padLeft(2, '0')} - ${DateTime.parse(event['end_time']).hour}:${DateTime.parse(event['end_time']).minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteEvent(event['id']),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}