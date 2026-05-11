import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_client.dart';

class MapsScreen extends StatefulWidget {
  final ApiClient apiClient;

  const MapsScreen({super.key, required this.apiClient});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  List<dynamic> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final routes = await widget.apiClient.getRoutes();
    if (!mounted) return;
    setState(() {
      _routes = routes;
      _loading = false;
    });
  }

  Future<void> _buildRoute() async {
    final start = _startController.text.trim();
    final end = _endController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите адреса'), backgroundColor: Colors.red),
      );
      return;
    }

    // Открываем Яндекс.Карты с маршрутом
    final url = Uri.encodeFull(
      'https://yandex.ru/maps/?rtext=$start~$end&rtt=auto',
    );
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // Сохраняем маршрут на бэкенде
    await widget.apiClient.saveRoute(start, end);
    _loadRoutes();

    _startController.clear();
    _endController.clear();
  }

  Future<void> _deleteRoute(int id) async {
    await widget.apiClient.deleteRoute(id);
    _loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Карты', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ввод адресов
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _startController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Откуда (адрес)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.circle, color: Colors.greenAccent, size: 14),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _endController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Куда (адрес)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.circle, color: Colors.redAccent, size: 14),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _buildRoute,
                      icon: const Icon(Icons.directions_car),
                      label: const Text('Построить маршрут'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B6EF3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Сохранённые маршруты', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Список маршрутов
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _routes.isEmpty
                      ? const Center(child: Text('Нет сохранённых маршрутов', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          itemCount: _routes.length,
                          itemBuilder: (_, i) {
                            final route = _routes[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.route, color: Color(0xFF1B6EF3)),
                                title: Text(route['name'] ?? 'Маршрут', style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  '${route['start_point'] ?? ''} → ${route['end_point'] ?? ''}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteRoute(route['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}