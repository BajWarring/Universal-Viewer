import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:archive/archive_io.dart';

enum FileItemType { folder, file }
enum SortBy { name, size, date, type }
enum SortOrder { asc, desc }

class FileItem {
  final String name;
  final String path;
  final FileItemType type;
  final int size;
  final DateTime modified;
  final int itemCount;
  final String? mimeType;

  FileItem({required this.name, required this.path, required this.type, required this.size, required this.modified, this.itemCount = 0, this.mimeType});

  bool get isHidden => name.startsWith('.');
  bool get isFolder => type == FileItemType.folder;
  bool get isArchive => ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'].contains(ext.toLowerCase());
  bool get isImage => ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/bmp', 'image/svg+xml'].contains(mimeType);
  bool get isVideo => mimeType?.startsWith('video/') ?? false;
  bool get isAudio => mimeType?.startsWith('audio/') ?? false;
  bool get isPdf => mimeType == 'application/pdf';
  bool get isText => mimeType?.startsWith('text/') ?? false;
  bool get isApk => ext.toLowerCase() == '.apk';

  String get ext => isFolder ? '' : p.extension(name);
  IconData get icon {
    if (isFolder) return Icons.folder_rounded;
    final e = ext.toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic', '.svg'].contains(e)) return Icons.image_rounded;
    if (['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg'].contains(e)) return Icons.movie_rounded;
    if (['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.opus'].contains(e)) return Icons.music_note_rounded;
    if (['.pdf'].contains(e)) return Icons.picture_as_pdf_rounded;
    if (['.doc', '.docx', '.odt'].contains(e)) return Icons.description_rounded;
    if (['.xls', '.xlsx', '.ods', '.csv'].contains(e)) return Icons.table_chart_rounded;
    if (['.ppt', '.pptx', '.odp'].contains(e)) return Icons.slideshow_rounded;
    if (['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz'].contains(e)) return Icons.folder_zip_rounded;
    if (['.apk'].contains(e)) return Icons.android_rounded;
    if (['.txt', '.md', '.log'].contains(e)) return Icons.text_snippet_rounded;
    if (['.py', '.js', '.ts', '.dart', '.java', '.cpp', '.c', '.h', '.go', '.rs', '.php', '.rb', '.swift', '.kt'].contains(e)) return Icons.code_rounded;
    if (['.json', '.xml', '.yaml', '.yml', '.html', '.css', '.sh'].contains(e)) return Icons.data_object_rounded;
    if (['.ttf', '.otf', '.woff', '.woff2'].contains(e)) return Icons.font_download_rounded;
    if (['.exe', '.msi', '.dmg', '.deb', '.rpm'].contains(e)) return Icons.settings_applications_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color getColor(Color primary) {
    if (isFolder) return primary;
    final e = ext.toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic', '.svg'].contains(e)) return const Color(0xFF0EA5E9);
    if (['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm'].contains(e)) return const Color(0xFFEC4899);
    if (['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a'].contains(e)) return const Color(0xFFA855F7);
    if (['.pdf'].contains(e)) return const Color(0xFFEF4444);
    if (['.doc', '.docx', '.odt'].contains(e)) return const Color(0xFF2B579A);
    if (['.xls', '.xlsx', '.ods', '.csv'].contains(e)) return const Color(0xFF217346);
    if (['.ppt', '.pptx', '.odp'].contains(e)) return const Color(0xFFD24726);
    if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(e)) return const Color(0xFFF59E0B);
    if (['.apk'].contains(e)) return const Color(0xFF22C55E);
    if (['.txt', '.md', '.log'].contains(e)) return const Color(0xFF6366F1);
    if (['.py', '.js', '.ts', '.dart', '.java', '.cpp', '.c'].contains(e)) return const Color(0xFF10B981);
    return const Color(0xFF64748B);
  }
}

class FileSystemService {
  static Future<List<FileItem>> listDirectory(String dirPath, {bool showHidden = false, SortBy sortBy = SortBy.name, SortOrder sortOrder = SortOrder.asc}) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return [];
      final List<FileItem> items = [];
      await for (final entity in dir.list(followLinks: false)) {
        try {
          final stat = await entity.stat();
          final name = p.basename(entity.path);
          if (!showHidden && name.startsWith('.')) continue;

          if (entity is Directory) {
            int count = 0;
            try { count = await dir.list().length; } catch (_) {}
            items.add(FileItem(name: name, path: entity.path, type: FileItemType.folder, size: 0, modified: stat.modified, itemCount: count));
          } else if (entity is File) {
            final mime = lookupMimeType(entity.path);
            items.add(FileItem(name: name, path: entity.path, type: FileItemType.file, size: stat.size, modified: stat.modified, mimeType: mime));
          }
        } catch (_) {}
      }
      _sort(items, sortBy, sortOrder);
      return items;
    } catch (e) { return []; }
  }

  static void _sort(List<FileItem> items, SortBy sortBy, SortOrder order) {
    final folders = items.where((i) => i.isFolder).toList();
    final files = items.where((i) => !i.isFolder).toList();
    int compare(FileItem a, FileItem b) {
      switch (sortBy) {
        case SortBy.name: return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortBy.size: return a.size.compareTo(b.size);
        case SortBy.date: return a.modified.compareTo(b.modified);
        case SortBy.type: return a.ext.compareTo(b.ext);
      }
    }
    folders.sort((a, b) => order == SortOrder.asc ? compare(a, b) : compare(b, a));
    files.sort((a, b) => order == SortOrder.asc ? compare(a, b) : compare(b, a));
    items.clear();
    items.addAll(folders);
    items.addAll(files);
  }

  static Future<bool> deleteItem(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.directory) { await Directory(path).delete(recursive: true); } else { await File(path).delete(); }
      return true;
    } catch (_) { return false; }
  }

  static Future<bool> renameItem(String oldPath, String newName) async {
    try {
      final dir = p.dirname(oldPath);
      final newPath = p.join(dir, newName);
      final type = FileSystemEntity.typeSync(oldPath);
      if (type == FileSystemEntityType.directory) { await Directory(oldPath).rename(newPath); } else { await File(oldPath).rename(newPath); }
      return true;
    } catch (_) { return false; }
  }

  static Future<bool> createFolder(String parentPath, String name) async {
    try { await Directory(p.join(parentPath, name)).create(recursive: true); return true; } catch (_) { return false; }
  }

  static Future<bool> copyItem(String srcPath, String destDir) async {
    try {
      final name = p.basename(srcPath);
      final destPath = p.join(destDir, name);
      final type = FileSystemEntity.typeSync(srcPath);
      if (type == FileSystemEntityType.directory) {
        await _copyDirectory(Directory(srcPath), Directory(destPath));
      } else {
        await File(srcPath).copy(destPath);
      }
      return true;
    } catch (_) { return false; }
  }

  static Future<void> _copyDirectory(Directory src, Directory dest) async {
    await dest.create(recursive: true);
    await for (final entity in src.list()) {
      final target = p.join(dest.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(target));
      } else if (entity is File) {
        await entity.copy(target);
      }
    }
  }

  static Future<bool> moveItem(String srcPath, String destDir) async {
    try {
      final name = p.basename(srcPath);
      final destPath = p.join(destDir, name);
      final type = FileSystemEntity.typeSync(srcPath);
      if (type == FileSystemEntityType.directory) {
        await Directory(srcPath).rename(destPath);
      } else {
        await File(srcPath).rename(destPath);
      }
      return true;
    } catch (e) {
      if (await copyItem(srcPath, destDir)) { return deleteItem(srcPath); }
      return false;
    }
  }

  static Future<bool> compressItems(List<String> srcPaths, String destPath) async {
    try {
      var encoder = ZipFileEncoder();
      encoder.create(destPath);
      for (String path in srcPaths) {
        var stat = await FileStat.stat(path);
        if (stat.type == FileSystemEntityType.directory) {
          encoder.addDirectory(Directory(path));
        } else {
          encoder.addFile(File(path));
        }
      }
      encoder.close();
      return true;
    } catch (e) { return false; }
  }

  static Future<bool> extractArchive(String archivePath, String destDir) async {
    try {
      final bytes = File(archivePath).readAsBytesSync();
      Archive archive;
      if (archivePath.toLowerCase().endsWith('.zip')) {
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (archivePath.toLowerCase().endsWith('.tar')) {
        archive = TarDecoder().decodeBytes(bytes);
      } else if (archivePath.toLowerCase().endsWith('.gz')) {
        archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
      } else {
        return false;
      }
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(p.join(destDir, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(p.join(destDir, filename)).createSync(recursive: true);
        }
      }
      return true;
    } catch (e) { return false; }
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatDate(DateTime date, {bool relative = true}) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (relative) {
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  static Future<List<FileItem>> searchFiles(String rootPath, String query, {bool includeHidden = false, bool recursive = true}) async {
    final results = <FileItem>[];
    final q = query.toLowerCase();
    Future<void> searchDir(String dirPath) async {
      try {
        final dir = Directory(dirPath);
        await for (final entity in dir.list(followLinks: false)) {
          final name = p.basename(entity.path);
          if (!includeHidden && name.startsWith('.')) continue;
          final stat = await entity.stat();
          if (name.toLowerCase().contains(q)) {
            final mime = entity is File ? lookupMimeType(entity.path) : null;
            results.add(FileItem(name: name, path: entity.path, type: entity is Directory ? FileItemType.folder : FileItemType.file, size: entity is File ? stat.size : 0, modified: stat.modified, mimeType: mime));
          }
          if (recursive && entity is Directory) { await searchDir(entity.path); }
        }
      } catch (_) {}
    }
    await searchDir(rootPath);
    return results;
  }

  static Future<List<FileItem>> getRecentFiles(String rootPath, {int limit = 20}) async {
    final all = <FileItem>[];
    Future<void> scanDir(String dirPath, int depth) async {
      if (depth > 4) return;
      try {
        final dir = Directory(dirPath);
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is File) {
            final name = p.basename(entity.path);
            if (name.startsWith('.')) continue;
            final stat = await entity.stat();
            final mime = lookupMimeType(entity.path);
            all.add(FileItem(name: name, path: entity.path, type: FileItemType.file, size: stat.size, modified: stat.modified, mimeType: mime));
          } else if (entity is Directory) {
            await scanDir(entity.path, depth + 1);
          }
        }
      } catch (_) {}
    }
    await scanDir(rootPath, 0);
    all.sort((a, b) => b.modified.compareTo(a.modified));
    return all.take(limit).toList();
  }
}
