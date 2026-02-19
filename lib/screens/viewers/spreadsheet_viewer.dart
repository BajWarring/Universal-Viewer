import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';

class SpreadsheetViewer extends StatefulWidget {
  final String filePath;
  final String ext;
  const SpreadsheetViewer({super.key, required this.filePath, required this.ext});

  @override
  State<SpreadsheetViewer> createState() => _SpreadsheetViewerState();
}

class _SpreadsheetViewerState extends State<SpreadsheetViewer> {
  List<List<String>> _rows = [];
  List<String> _sheetNames = [];
  int _currentSheet = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ext = widget.ext.toLowerCase();
      if (ext == 'csv' || ext == 'tsv') {
        await _loadCsv(ext == 'tsv');
      } else {
        await _loadExcel();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadCsv(bool isTsv) async {
    final content = await File(widget.filePath).readAsString();
    final rows = const CsvToListConverter().convert(content, fieldDelimiter: isTsv ? '\t' : ',');
    if (mounted) setState(() {
      _rows = rows.map((r) => r.map((c) => c.toString()).toList()).toList();
      _loading = false;
    });
  }

  Future<void> _loadExcel() async {
    final bytes = await File(widget.filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    _sheetNames = excel.sheets.keys.toList();
    _loadSheet(excel, 0);
  }

  void _loadSheet(Excel excel, int idx) {
    final sheet = excel.sheets[_sheetNames[idx]]!;
    final rows = sheet.rows
        .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
        .toList();
    if (mounted) setState(() { _rows = rows; _currentSheet = idx; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF217346)));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white54)));

    return Column(
      children: [
        if (_sheetNames.isNotEmpty)
          Container(
            height: 44,
            color: const Color(0xFF14141F),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: _sheetNames.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _currentSheet = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _currentSheet == i ? const Color(0xFF217346) : const Color(0xFF0D0D14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _currentSheet == i ? const Color(0xFF217346) : Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Text(_sheetNames[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _currentSheet == i ? Colors.white : Colors.white54)),
                ),
              ),
            ),
          ),
        Expanded(
          child: _rows.isEmpty
              ? const Center(child: Text('Empty spreadsheet', style: TextStyle(color: Colors.white38)))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF217346).withOpacity(0.2)),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return const Color(0xFF217346).withOpacity(0.1);
                        return null;
                      }),
                      border: TableBorder.all(color: Colors.white10, width: 0.5),
                      columnSpacing: 20,
                      columns: _rows.isNotEmpty
                          ? _rows.first.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))).toList()
                          : [const DataColumn(label: Text(''))],
                      rows: _rows.skip(1).map((row) => DataRow(
                        cells: row.map((cell) => DataCell(Text(cell, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')))).toList(),
                      )).toList(),
                    ),
                  ),
                ),
        ),
        Container(
          color: const Color(0xFF14141F),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${_rows.length > 0 ? _rows.length - 1 : 0} rows · ${_rows.isNotEmpty ? _rows.first.length : 0} columns',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
            ],
          ),
        ),
      ],
    );
  }
}
