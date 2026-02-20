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
  late final FileSystemProvider _provider;

  @override
  SearchState build() {
    _provider = sl<FileSystemProvider>(instanceName: 'local');
    return const SearchState();
  }

  void toggleRegex(bool value) {
    state = state.copyWith(useRegex: value);
    if (state.query.isNotEmpty) performSearch(state.query, '/storage/emulated/0');
  }

  Future<void> performSearch(String query, String startPath) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(isSearching: false, results: [], query: '');
      return;
    }

    state = state.copyWith(isSearching: true, query: query, results: []);
    final results = <OmniNode>[];
    
    // Determine matching logic (Standard vs Regex)
    bool matches(String filename) {
      if (state.useRegex) {
        try {
          final regex = RegExp(query, caseSensitive: false);
          return regex.hasMatch(filename);
        } catch (e) {
          return false; // Invalid regex
        }
      }
      return filename.toLowerCase().contains(query.toLowerCase());
    }

    // Recursive search function
    Future<void> searchDirectory(String path) async {
      try {
        final nodes = await _provider.listDirectory(path);
        for (final node in nodes) {
          // Check against HTML settings for hidden files
          if (node.isHidden) continue; 

          if (matches(node.name)) {
            results.add(node);
            // Update UI incrementally so it doesn't freeze waiting for the whole drive
            state = state.copyWith(results: List.from(results)); 
          }
          // If subfolders setting is enabled, recurse
          if (node.isFolder) {
            await searchDirectory(node.path);
          }
        }
      } catch (e) {
        // Skip inaccessible directories
      }
    }

    await searchDirectory(startPath);
    state = state.copyWith(isSearching: false);
  }

  void clearSearch() {
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
