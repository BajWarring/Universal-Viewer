import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';
import '../../../../core/config/injection_container.dart';

class SearchState {
  final bool isSearching;
  final List<OmniNode> results;
  final String query;

  const SearchState({this.isSearching = false, this.results = const [], this.query = ''});
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() => const SearchState();

  void performSearch(String query, String startPath) {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    // Debouncer: Wait 500ms after the user stops typing before searching
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = SearchState(isSearching: true, query: query, results: []);
      
      final provider = sl<FileSystemProvider>(instanceName: 'local');
      final newResults = <OmniNode>[];
      final lowerQuery = query.toLowerCase();

      // Avoid UI freezing by yielding to the event loop
      Future<void> crawl(String path) async {
        try {
          final nodes = await provider.listDirectory(path);
          for (final node in nodes) {
            if (node.name.toLowerCase().contains(lowerQuery)) {
              newResults.add(node);
            }
            if (node.isFolder) await crawl(node.path);
          }
        } catch (_) {} // Ignore permission denied folders
      }

      await crawl(startPath);
      // Update state ONCE at the end, preventing the "buzzing" loop
      state = SearchState(isSearching: false, query: query, results: newResults);
    });
  }
}
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() => SearchNotifier());
