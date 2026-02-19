import 'package:flutter/material.dart';
import '../utils/format_registry.dart';
import '../screens/home_screen.dart';

class FormatSearchDelegate extends SearchDelegate<FileFormat?> {
  @override
  String get searchFieldLabel => 'Search formats...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF14141F)),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = query.isEmpty ? FormatRegistry.all : FormatRegistry.search(query);
    return Container(
      color: const Color(0xFF0D0D14),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (_, i) {
          final f = results[i];
          return ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: f.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(f.icon, color: f.color, size: 20),
            ),
            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text(f.description, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
            trailing: Text('.${f.ext.toUpperCase()}', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: f.color, fontWeight: FontWeight.w700)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormatInfoScreen(format: f))),
          );
        },
      ),
    );
  }
}
