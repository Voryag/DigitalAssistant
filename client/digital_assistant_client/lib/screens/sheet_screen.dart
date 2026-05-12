import 'package:flutter/material.dart';
import '../services/api_client.dart';

class SheetsScreen extends StatefulWidget {
  final ApiClient apiClient;
  const SheetsScreen({super.key, required this.apiClient});

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  List<dynamic> _sheets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sheets = await widget.apiClient.getSheets();
    if (!mounted) return;
    setState(() {
      _sheets = sheets;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final titleC = TextEditingController();
    final headersC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Новая таблица', style: TextStyle(color: Colors.white)),
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
                controller: headersC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Колонки (через запятую)',
                  hintText: 'Название, Автор, Год',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF0D1B2A),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
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
    );

    if (ok == true && titleC.text.trim().isNotEmpty) {
      final headers = headersC.text.isEmpty
          ? <String>[]
          : headersC.text.split(',').map((s) => s.trim()).toList();

      await widget.apiClient.createSheet(titleC.text.trim(), headers, []);
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await widget.apiClient.deleteSheet(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Таблицы', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B6EF3),
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sheets.isEmpty
              ? const Center(
                  child: Text('Нет таблиц', style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sheets.length,
                  itemBuilder: (_, i) {
                    final sheet = _sheets[i];
                    final headers = sheet['headers'] as List<dynamic>? ?? [];
                    final rows = sheet['rows'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: const Icon(Icons.table_chart, color: Color(0xFF1B6EF3)),
                        title: Text(sheet['title'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${headers.length} колонок · ${rows.length} строк',
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        children: [
                          if (headers.isNotEmpty || rows.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  border: TableBorder.all(color: Colors.white24),
                                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0D1B2A)),
                                  dataRowColor: WidgetStateProperty.all(const Color(0xFF1B2838)),
                                  columns: headers.isNotEmpty
                                      ? headers.map((h) => DataColumn(
                                          label: Text(h.toString(),
                                              style: const TextStyle(color: Color(0xFF1B6EF3), fontWeight: FontWeight.bold))))
                                          .toList()
                                      : [const DataColumn(label: Text('Пусто'))],
                                  rows: rows.map((row) {
                                    final cells = row as List<dynamic>;
                                    return DataRow(
                                      cells: cells.map((cell) => DataCell(
                                        Text(cell.toString(), style: const TextStyle(color: Colors.white)))
                                      ).toList(),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF1B6EF3)),
                                  onPressed: () => _addRow(sheet['id'], headers.length),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _delete(sheet['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _addRow(int id, int columnCount) async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Добавить строку', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Значения через запятую',
            labelStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF0D1B2A),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B6EF3)),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (ok == true && controller.text.isNotEmpty) {
      final values = controller.text.split(',').map((s) => s.trim()).toList();
      await widget.apiClient.addRowToSheet(id, values);
      _load();
    }
  }
}