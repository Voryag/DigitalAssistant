import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:8000';
  
  String? _token;

  // Сохранить токен после логина
  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json; charset=utf-8'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _token = data['access_token'];
    }
    return data;
  }

  //Заметки
  Future<List<dynamic>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<Map<String, dynamic>?> createNote(String title, String content, List<String> tags) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'ai_tags': tags,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> updateNote(int id, String title, String content, List<String> tags) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/$id'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'ai_tags': tags,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: _headers,
    );
    return response.statusCode == 204;
    }

  //Задачи
  Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<Map<String, dynamic>?> createTask({
    required String title,
    String? content,
    String? project,
    String? tags,
    String? priority,
    String? dueDate,
    List<String>? aiTags,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content ?? '',
        'project': project ?? '',
        'tags': tags ?? '',
        'priority': priority ?? 'medium',
        'due_date': dueDate,
        'ai_tags': aiTags?? [],
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> updateTask({
    required int id,
    required String title,
    String? content,
    String? project,
    String? tags,
    String? priority,
    String? dueDate,
    List<String>? aiTags,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content ?? '',
        'project': project ?? '',
        'priority': priority ?? 'medium',
        'due_date': dueDate,
        'ai_tags': tags ?? [],
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
    );
    return response.statusCode == 204;
  }


// Обновить приоритет задачи
Future<bool> updateTaskPriority(int id, String priority) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/tasks/$id/priority'),
    headers: _headers,
    body: jsonEncode({'priority': priority}),
  );
  return response.statusCode == 200;
}

// Отправить задачу в GitLab
Future<Map<String, dynamic>?> exportToGitLab(int taskId, String title) async {
  final response = await http.post(
    Uri.parse('$baseUrl/gitlab/create-issue'),
    headers: _headers,
    body: jsonEncode({
      'title': title,
      'labels': ['digital-assistant'],
    }),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

  // AI-парсинг
  Future<Map<String, dynamic>?> parseAI(String text) async {
  final response = await http.post(
    Uri.parse('$baseUrl/ai/parse'),
    headers: _headers,
    body: jsonEncode({'text': text}),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
  }

  //Календарь
  Future<List<dynamic>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/calendar/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<bool> createEvent({
    required String title,
    String? content,
    required String startTime,
    required String endTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calendar/'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'start_time': startTime,
        'end_time': endTime,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/calendar/$id'),
      headers: _headers,
    );
    return response.statusCode == 204;
  }

  // Поиск
  Future<Map<String, dynamic>> search(String query) async {
      final response = await http.get(
        Uri.parse('$baseUrl/search/?q=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"query": query, "results": []};
    }

  //Статистика для дашборда
  Future<Map<String, dynamic>> getDashboardStats() async {
    final notes = await getNotes();
    final tasks = await getTasks();
    final events = await getEvents();

    final now = DateTime.now();
    final todayEvents = events.where((e) {
      final start = DateTime.parse(e['start_time']);
      return start.year == now.year && start.month == now.month && start.day == now.day;
    }).length;

    final tasksByPriority = {'easy': 0, 'medium': 0, 'hard': 0};
    for (var t in tasks) {
      final p = t['priority'] ?? 'medium';
      tasksByPriority[p] = (tasksByPriority[p] ?? 0) + 1;
    }

    return {
      'total_notes': notes.length,
      'total_tasks': tasks.length,
      'total_events': events.length,
      'today_events': todayEvents,
      'tasks_easy': tasksByPriority['easy'] ?? 0,
      'tasks_medium': tasksByPriority['medium'] ?? 0,
      'tasks_hard': tasksByPriority['hard'] ?? 0,
    };
  }

  // Получить маршруты
  Future<List<dynamic>> getRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Сохранить маршрут
  Future<void> saveRoute(String start, String end) async {
    await http.post(
      Uri.parse('$baseUrl/routes/'),
      headers: _headers,
      body: jsonEncode({
        'name': '$start → $end',
        'start_point': start,
        'end_point': end,
      }),
    );
  }

  // Удалить маршрут
  Future<bool> deleteRoute(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$id'),
      headers: _headers,
    );
    return response.statusCode == 204;
  }
}