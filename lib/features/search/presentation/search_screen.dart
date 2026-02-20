import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/search_notifier.dart';
import '../../explorer/presentation/widgets/file_list_view.dart';
import '../../../../filesystem/application/directory_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    
    // We get the current path from the explorer to know where to start searching
    final currentPath = ref.read(directoryProvider).currentPath;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search files...',
            border: InputBorder.none,
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Debounce this in a production environment
            ref.read(searchProvider.notifier).performSearch(value, currentPath);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('.* Regex'),
                  selected: searchState.useRegex,
                  onSelected: (val) => ref.read(searchProvider.notifier).toggleRegex(val),
                  selectedColor: theme.colorScheme.primaryContainer,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Images'),
                  avatar: const Icon(Icons.image, size: 16),
                  onPressed: () {
                    _controller.text = r'\.(jpg|jpeg|png|gif|webp)$';
                    ref.read(searchProvider.notifier).toggleRegex(true);
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Large Files (>100MB)'),
                  avatar: const Icon(Icons.folder_zip, size: 16),
                  onPressed: () {
                    // Trigger advanced size filter logic
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (searchState.isSearching) const LinearProgressIndicator(),
          Expanded(
            child: searchState.results.isEmpty && !searchState.isSearching && searchState.query.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No files found'),
                      ],
                    ),
                  )
                : FileListView(nodes: searchState.results), // Reusing our widget from Phase 4!
          ),
        ],
      ),
    );
  }
}
