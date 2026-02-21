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
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    final currentPath = ref.read(directoryProvider).currentPath;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search files...',
            border: InputBorder.none,
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _controller.clear(); ref.read(searchProvider.notifier).clearSearch(); })
                : null,
          ),
          onChanged: (v) => ref.read(searchProvider.notifier).performSearch(v, currentPath.isEmpty || currentPath == 'Root' ? '/storage/emulated/0' : currentPath),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              FilterChip(label: const Text('.* Regex'), selected: searchState.useRegex,
                onSelected: (v) => ref.read(searchProvider.notifier).toggleRegex(v),
                selectedColor: theme.colorScheme.primaryContainer),
              const SizedBox(width: 8),
              ActionChip(label: const Text('Images'), avatar: const Icon(Icons.image_rounded, size: 16),
                onPressed: () { _controller.text = r'\.(jpg|jpeg|png|gif|webp)$'; ref.read(searchProvider.notifier).toggleRegex(true); }),
              const SizedBox(width: 8),
              ActionChip(label: const Text('Videos'), avatar: const Icon(Icons.video_library_rounded, size: 16),
                onPressed: () { _controller.text = r'\.(mp4|mkv|avi|webm)$'; ref.read(searchProvider.notifier).toggleRegex(true); }),
              const SizedBox(width: 8),
              ActionChip(label: const Text('Documents'), avatar: const Icon(Icons.description_rounded, size: 16),
                onPressed: () { _controller.text = r'\.(pdf|doc|docx|txt)$'; ref.read(searchProvider.notifier).toggleRegex(true); }),
            ]),
          ),
        ),
      ),
      body: Column(children: [
        if (searchState.isSearching) LinearProgressIndicator(color: theme.colorScheme.primary),
        Expanded(child: searchState.results.isEmpty && !searchState.isSearching && searchState.query.isNotEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text('No files found for "${searchState.query}"', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ]))
            : FileListView(nodes: searchState.results)),
      ]),
    );
  }
}
