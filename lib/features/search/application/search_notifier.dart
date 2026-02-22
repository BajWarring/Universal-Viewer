import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../filesystem/domain/entities/omni_node.dart';

class SearchState {
  final bool isSearching;
  final List<OmniNode> results;
  final String query;
  final bool useRegex;

  const SearchState({this.isSearching = false, this.results = const [], this.query = '', this.useRegex = false});

  SearchState copyWith({bool? isSearching, List<OmniNode>? results, String? query, bool? useRegex}) {
    return SearchState(
      isSearching: isSearching ?? this.isSearching, 
      results: results ?? this.results, 
      query: query ?? this.query, 
      useRegex: useRegex ?? this.useRegex
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;
  ReceivePort? _currentPort;
  Isolate? _currentIsolate;

  @override
  SearchState build() => const SearchState();

  void toggleRegex(bool value) { 
    state = state.copyWith(useRegex: value); 
    if (state.query.isNotEmpty) performSearch(state.query, '/storage/emulated/0'); 
  }
  
  void clearSearch() { 
    _debounce?.cancel();
    _killIsolate();
    state = const SearchState(); 
  }

  void _killIsolate() {
    _currentPort?.close();
    _currentIsolate?.kill(priority: Isolate.immediate);
    _currentPort = null;
    _currentIsolate = null;
  }

  void performSearch(String query, String startPath) {
    if (query.trim().isEmpty) { 
      clearSearch(); 
      return;
    }
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      _killIsolate();
      state = state.copyWith(isSearching: true, query: query, results: []);

      _currentPort = ReceivePort();
      _currentPort!.listen((message) {
        if (message is List<OmniNode>) {
          // Append batch results to UI
          state = state.copyWith(results: [...state.results, ...message]);
        } else if (message == "DONE") {
          state = state.copyWith(isSearching: false);
          _killIsolate();
        }
      });

      _currentIsolate = await Isolate.spawn(
        _isolateSearchTask, 
        [query, startPath, state.useRegex, _currentPort!.sendPort]
      );
    });
  }

  // --- ISOLATE ENTRY POINT --- //
  static Future<void> _isolateSearchTask(List<dynamic> args) async {
    final query = args[0] as String;
    final startPath = args[1] as String;
    final useRegex = args[2] as bool;
    final sendPort = args[3] as SendPort;

    final lowerQuery = query.toLowerCase();
    RegExp? regex;
    if (useRegex) {
      try { regex = RegExp(query, caseSensitive: false); } catch (_) {}
    }

    final dir = Directory(startPath);
    if (!dir.existsSync()) {
      sendPort.send("DONE");
      return;
    }

    List<OmniNode> batch = [];
    
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        final name = p.basename(entity.path);
        bool matches = false;
        
        if (useRegex && regex != null) {
          matches = regex.hasMatch(name);
        } else {
          matches = name.toLowerCase().contains(lowerQuery);
        }

        if (matches) {
          final stat = entity.statSync();
          final isFolder = entity is Directory;
          batch.add(OmniNode(
            name: name,
            path: entity.path,
            size: stat.size,
            modified: stat.modified,
            isFolder: isFolder,
            extension: isFolder ? '' : p.extension(name).replaceAll('.', ''),
          ));

          // Send results to main UI in batches of 20 to keep 60fps
          if (batch.length >= 20) {
            sendPort.send(List<OmniNode>.from(batch));
            batch.clear();
          }
        }
      }
    } catch (_) {
      // Ignore permission errors in restricted subfolders
    }

    if (batch.isNotEmpty) sendPort.send(batch);
    sendPort.send("DONE");
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() => SearchNotifier());
