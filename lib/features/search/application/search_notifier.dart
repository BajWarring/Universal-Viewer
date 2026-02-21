import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../../../filesystem/domain/repositories/file_system_provider.dart';
import '../../../../core/config/injection_container.dart';

class SearchState {
  final bool isSearching;
  final List<OmniNode> results;
  final String query;
  final bool useRegex;

  const SearchState({
    this.isSearching = false, 
    this.results = const [], 
    this.query = '',
    this.useRegex = false,
  });

  SearchState copyWith({bool? isSearching, List<OmniNode>? results, String? query, bool? useRegex}) {
    return SearchState(
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      query: query ?? this.query,
      useRegex: useRegex ?? this.useRegex,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() => const SearchState();

  void toggleRegex(bool value) {
    state = state.copyWith(useRegex: value);
    if (state.query.isNotEmpty) performSearch(state.query, '/storage/emulated/0');
  }

  void clearSearch() {
    state = const SearchState();
  }

  void performSearch(String query, String startPath) {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    // Debouncer: Wait 500ms after the user stops typing before searching
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = state.copyWith(isSearching: true, query: query, results: []);
      
      final provider = sl<FileSystemProvider>(instanceName: 'local');
      final newResults = <OmniNode>[];
      final lowerQuery = query.toLowerCase();

      bool matches(String filename) {
        if (state.useRegex) {
          try {
            final regex = RegExp(query, caseSensitive: false);
            return regex.hasMatch(filename);
          } catch (e) {
            return false; // Invalid regex
          }
        }
        return filename.toLowerCase().contains(lowerQuery);
      }

      // Avoid UI freezing by yielding to the event loop
      Future<void> crawl(String path) async {
        try {
          final nodes = await provider.listDirectory(path);
          for (final node in nodes) {
            if (matches(node.name)) {
              newResults.add(node);
            }
            if (node.isFolder) await crawl(node.path);
          }
        } catch (_) {} // Ignore permission denied folders
      }

      await crawl(startPath);
      // Update state ONCE at the end
      state = state.copyWith(isSearching: false, results: newResults);
    });
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() => SearchNotifier());
