import 'package:flutter/material.dart';

enum FormatCategory {
  documents,
  images,
  video,
  audio,
  archives,
  code,
  database,
  fonts,
}

enum ViewerType {
  text,
  code,
  image,
  svg,
  pdf,
  video,
  audio,
  epub,
  spreadsheet,
  archive,
  font,
  hex, // fallback for binary files
}

class FileFormat {
  final String ext;
  final String name;
  final String description;
  final FormatCategory category;
  final ViewerType viewer;
  final Color color;
  final IconData icon;

  const FileFormat({
    required this.ext,
    required this.name,
    required this.description,
    required this.category,
    required this.viewer,
    required this.color,
    required this.icon,
  });
}

class FormatRegistry {
  static const List<FileFormat> all = [
    // ── DOCUMENTS ─────────────────────────────────────────────
    FileFormat(ext: 'txt', name: 'Plain Text', description: 'Simple unformatted text', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF6C63FF), icon: Icons.text_snippet_outlined),
    FileFormat(ext: 'rtf', name: 'Rich Text Format', description: 'Cross-platform formatted text', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF6C63FF), icon: Icons.article_outlined),
    FileFormat(ext: 'md', name: 'Markdown', description: 'Lightweight markup language', category: FormatCategory.documents, viewer: ViewerType.code, color: Color(0xFF6C63FF), icon: Icons.code_outlined),
    FileFormat(ext: 'tex', name: 'LaTeX', description: 'Document typesetting language', category: FormatCategory.documents, viewer: ViewerType.code, color: Color(0xFF6C63FF), icon: Icons.functions_outlined),
    FileFormat(ext: 'doc', name: 'Word Document (Legacy)', description: 'Microsoft Word 97-2003', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF2B579A), icon: Icons.description_outlined),
    FileFormat(ext: 'docx', name: 'Word Document', description: 'Microsoft Word Open XML', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF2B579A), icon: Icons.description_outlined),
    FileFormat(ext: 'odt', name: 'OpenDocument Text', description: 'LibreOffice text format', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF0087CA), icon: Icons.description_outlined),
    FileFormat(ext: 'pdf', name: 'PDF Document', description: 'Portable Document Format', category: FormatCategory.documents, viewer: ViewerType.pdf, color: Color(0xFFE53935), icon: Icons.picture_as_pdf_outlined),
    FileFormat(ext: 'wps', name: 'WPS Document', description: 'Kingsoft Office format', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFFFF5722), icon: Icons.description_outlined),
    FileFormat(ext: 'pages', name: 'Apple Pages', description: 'Apple word processor', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF9500), icon: Icons.description_outlined),
    FileFormat(ext: 'xls', name: 'Excel (Legacy)', description: 'Microsoft Excel 97-2003', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF217346), icon: Icons.table_chart_outlined),
    FileFormat(ext: 'xlsx', name: 'Excel Spreadsheet', description: 'Microsoft Excel Open XML', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF217346), icon: Icons.table_chart_outlined),
    FileFormat(ext: 'xlsm', name: 'Excel Macro-Enabled', description: 'Excel with macros', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF217346), icon: Icons.table_chart_outlined),
    FileFormat(ext: 'ods', name: 'OpenDocument Sheet', description: 'LibreOffice spreadsheet', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF0087CA), icon: Icons.table_chart_outlined),
    FileFormat(ext: 'csv', name: 'CSV', description: 'Comma-separated values', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF26DE81), icon: Icons.grid_on_outlined),
    FileFormat(ext: 'tsv', name: 'TSV', description: 'Tab-separated values', category: FormatCategory.documents, viewer: ViewerType.spreadsheet, color: Color(0xFF26DE81), icon: Icons.grid_on_outlined),
    FileFormat(ext: 'ppt', name: 'PowerPoint (Legacy)', description: 'Microsoft PowerPoint 97-2003', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFD24726), icon: Icons.slideshow_outlined),
    FileFormat(ext: 'pptx', name: 'PowerPoint', description: 'Microsoft PowerPoint Open XML', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFD24726), icon: Icons.slideshow_outlined),
    FileFormat(ext: 'odp', name: 'OpenDocument Presentation', description: 'LibreOffice presentation', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFF0087CA), icon: Icons.slideshow_outlined),
    FileFormat(ext: 'key', name: 'Apple Keynote', description: 'Apple presentation format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF9500), icon: Icons.slideshow_outlined),
    FileFormat(ext: 'epub', name: 'EPUB Ebook', description: 'Open standard ebook format', category: FormatCategory.documents, viewer: ViewerType.epub, color: Color(0xFF6C63FF), icon: Icons.menu_book_outlined),
    FileFormat(ext: 'mobi', name: 'Mobipocket', description: 'Amazon Kindle format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF9900), icon: Icons.menu_book_outlined),
    FileFormat(ext: 'azw', name: 'Amazon Kindle', description: 'Kindle ebook format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF9900), icon: Icons.menu_book_outlined),
    FileFormat(ext: 'azw3', name: 'Kindle Format 8', description: 'Enhanced Kindle format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF9900), icon: Icons.menu_book_outlined),
    FileFormat(ext: 'fb2', name: 'FictionBook 2', description: 'XML-based ebook format', category: FormatCategory.documents, viewer: ViewerType.text, color: Color(0xFF6C63FF), icon: Icons.menu_book_outlined),
    FileFormat(ext: 'djvu', name: 'DjVu', description: 'Scanned document format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFF795548), icon: Icons.picture_as_pdf_outlined),
    FileFormat(ext: 'indd', name: 'Adobe InDesign', description: 'Professional layout file', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFFFF3366), icon: Icons.design_services_outlined),
    FileFormat(ext: 'idml', name: 'InDesign Markup', description: 'InDesign interchange format', category: FormatCategory.documents, viewer: ViewerType.code, color: Color(0xFFFF3366), icon: Icons.design_services_outlined),
    FileFormat(ext: 'pub', name: 'Microsoft Publisher', description: 'Desktop publishing format', category: FormatCategory.documents, viewer: ViewerType.hex, color: Color(0xFF0078D4), icon: Icons.newspaper_outlined),

    // ── IMAGES ─────────────────────────────────────────────────
    FileFormat(ext: 'jpg', name: 'JPEG Image', description: 'Lossy compressed photo', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'jpeg', name: 'JPEG Image', description: 'Lossy compressed photo', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'png', name: 'PNG Image', description: 'Lossless with transparency', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'gif', name: 'GIF Image', description: 'Animated & static images', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.gif_outlined),
    FileFormat(ext: 'bmp', name: 'Bitmap Image', description: 'Uncompressed Windows bitmap', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'tiff', name: 'TIFF Image', description: 'High-quality lossless image', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'tif', name: 'TIF Image', description: 'High-quality lossless image', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'webp', name: 'WebP Image', description: 'Modern web image format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'avif', name: 'AVIF Image', description: 'AV1-based image format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'heic', name: 'HEIC Image', description: 'Apple high-efficiency image', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'ico', name: 'Windows Icon', description: 'Windows application icon', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF00E5FF), icon: Icons.image_outlined),
    FileFormat(ext: 'dng', name: 'Digital Negative (RAW)', description: 'Adobe universal RAW format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'cr2', name: 'Canon RAW v2', description: 'Canon digital camera RAW', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'cr3', name: 'Canon RAW v3', description: 'Canon modern RAW format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'nef', name: 'Nikon RAW', description: 'Nikon Electronic Format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'arw', name: 'Sony RAW', description: 'Sony Alpha RAW format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'raf', name: 'Fujifilm RAW', description: 'Fujifilm RAW format', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'orf', name: 'Olympus RAW', description: 'Olympus camera RAW', category: FormatCategory.images, viewer: ViewerType.image, color: Color(0xFF64B5F6), icon: Icons.camera_outlined),
    FileFormat(ext: 'svg', name: 'SVG Vector', description: 'Scalable vector graphics', category: FormatCategory.images, viewer: ViewerType.svg, color: Color(0xFF00BCD4), icon: Icons.scatter_plot_outlined),
    FileFormat(ext: 'ai', name: 'Adobe Illustrator', description: 'Illustrator artwork file', category: FormatCategory.images, viewer: ViewerType.hex, color: Color(0xFFFF7900), icon: Icons.brush_outlined),
    FileFormat(ext: 'eps', name: 'Encapsulated PostScript', description: 'PostScript vector graphics', category: FormatCategory.images, viewer: ViewerType.text, color: Color(0xFF00BCD4), icon: Icons.scatter_plot_outlined),
    FileFormat(ext: 'cdr', name: 'CorelDRAW', description: 'CorelDRAW vector drawing', category: FormatCategory.images, viewer: ViewerType.hex, color: Color(0xFF00BCD4), icon: Icons.scatter_plot_outlined),

    // ── VIDEO ──────────────────────────────────────────────────
    FileFormat(ext: 'mp4', name: 'MP4 Video', description: 'Most common video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'mkv', name: 'Matroska Video', description: 'Open flexible container', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'avi', name: 'AVI Video', description: 'Audio Video Interleave', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'mov', name: 'QuickTime Movie', description: 'Apple QuickTime format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'wmv', name: 'Windows Media Video', description: 'Microsoft video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'flv', name: 'Flash Video', description: 'Adobe Flash video', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'webm', name: 'WebM Video', description: 'Open web video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'm4v', name: 'iTunes Video', description: 'Apple M4V video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'mpg', name: 'MPEG Video', description: 'MPEG-1/2 video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'mpeg', name: 'MPEG Video', description: 'MPEG-1/2 video format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: '3gp', name: '3GPP Video', description: 'Mobile phone video', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'mxf', name: 'MXF Professional', description: 'Professional media container', category: FormatCategory.video, viewer: ViewerType.hex, color: Color(0xFFE91E63), icon: Icons.movie_outlined),
    FileFormat(ext: 'mts', name: 'AVCHD Video', description: 'HD camcorder format', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'm2ts', name: 'Blu-ray Video', description: 'Blu-ray disc video', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.videocam_outlined),
    FileFormat(ext: 'vob', name: 'DVD Video Object', description: 'DVD video file', category: FormatCategory.video, viewer: ViewerType.video, color: Color(0xFFFF6B9D), icon: Icons.disc_full_outlined),

    // ── ARCHIVES ───────────────────────────────────────────────
    FileFormat(ext: 'zip', name: 'ZIP Archive', description: 'Most common archive format', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'rar', name: 'RAR Archive', description: 'Roshal Archive format', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: '7z', name: '7-Zip Archive', description: 'High-compression format', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'tar', name: 'TAR Archive', description: 'Unix file archive', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'gz', name: 'Gzip', description: 'GNU zip compressed file', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'tgz', name: 'Tar Gzip', description: 'Compressed tar archive', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'bz2', name: 'Bzip2', description: 'Bzip2 compressed file', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'xz', name: 'XZ Compressed', description: 'LZMA2 compression', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'lz', name: 'Lzip', description: 'Lzip compressed file', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'iso', name: 'Disc Image', description: 'Optical disc image', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFFFB300), icon: Icons.album_outlined),
    FileFormat(ext: 'cab', name: 'Cabinet Archive', description: 'Microsoft cabinet file', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),
    FileFormat(ext: 'arj', name: 'ARJ Archive', description: 'ARJ compressed archive', category: FormatCategory.archives, viewer: ViewerType.archive, color: Color(0xFFF7B731), icon: Icons.folder_zip_outlined),

    // ── CODE ───────────────────────────────────────────────────
    FileFormat(ext: 'c', name: 'C Source', description: 'C programming language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.code),
    FileFormat(ext: 'cpp', name: 'C++ Source', description: 'C++ programming language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.code),
    FileFormat(ext: 'h', name: 'C/C++ Header', description: 'Header file', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.code),
    FileFormat(ext: 'java', name: 'Java Source', description: 'Java programming language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFFF5722), icon: Icons.code),
    FileFormat(ext: 'py', name: 'Python Script', description: 'Python language file', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.code),
    FileFormat(ext: 'js', name: 'JavaScript', description: 'JavaScript source file', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFF7B731), icon: Icons.code),
    FileFormat(ext: 'ts', name: 'TypeScript', description: 'Typed JavaScript superset', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF0087CA), icon: Icons.code),
    FileFormat(ext: 'cs', name: 'C# Source', description: 'Microsoft C# language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF9B59B6), icon: Icons.code),
    FileFormat(ext: 'go', name: 'Go Source', description: 'Google Go language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF00D4FF), icon: Icons.code),
    FileFormat(ext: 'rs', name: 'Rust Source', description: 'Rust systems language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFFF6B35), icon: Icons.code),
    FileFormat(ext: 'swift', name: 'Swift Source', description: 'Apple Swift language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFFF5722), icon: Icons.code),
    FileFormat(ext: 'kt', name: 'Kotlin Source', description: 'JetBrains Kotlin', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF9B59B6), icon: Icons.code),
    FileFormat(ext: 'php', name: 'PHP Script', description: 'PHP language file', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF7B68EE), icon: Icons.code),
    FileFormat(ext: 'rb', name: 'Ruby Script', description: 'Ruby language file', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFCC342D), icon: Icons.code),
    FileFormat(ext: 'html', name: 'HTML Document', description: 'HyperText Markup Language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFE44D26), icon: Icons.web_outlined),
    FileFormat(ext: 'css', name: 'CSS Stylesheet', description: 'Cascading Style Sheets', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF264DE4), icon: Icons.style_outlined),
    FileFormat(ext: 'scss', name: 'Sass Stylesheet', description: 'CSS preprocessor', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFCC6699), icon: Icons.style_outlined),
    FileFormat(ext: 'json', name: 'JSON', description: 'JavaScript Object Notation', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFF7B731), icon: Icons.data_object_outlined),
    FileFormat(ext: 'xml', name: 'XML Document', description: 'Extensible Markup Language', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.data_object_outlined),
    FileFormat(ext: 'yaml', name: 'YAML', description: 'Human-readable data format', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFFFF6B9D), icon: Icons.data_object_outlined),
    FileFormat(ext: 'sh', name: 'Shell Script', description: 'Unix/Linux shell script', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF26DE81), icon: Icons.terminal_outlined),
    FileFormat(ext: 'bat', name: 'Batch File', description: 'Windows batch script', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF00D4FF), icon: Icons.terminal_outlined),
    FileFormat(ext: 'cmd', name: 'Command Script', description: 'Windows command script', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF00D4FF), icon: Icons.terminal_outlined),
    FileFormat(ext: 'ps1', name: 'PowerShell Script', description: 'Windows PowerShell', category: FormatCategory.code, viewer: ViewerType.code, color: Color(0xFF0087CA), icon: Icons.terminal_outlined),

    // ── DATABASE ───────────────────────────────────────────────
    FileFormat(ext: 'sql', name: 'SQL Script', description: 'Structured Query Language', category: FormatCategory.database, viewer: ViewerType.code, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'sqlite', name: 'SQLite Database', description: 'SQLite relational DB', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'db', name: 'Database File', description: 'Generic database file', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'db3', name: 'SQLite v3 Database', description: 'SQLite version 3', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'mdb', name: 'Access Database', description: 'Microsoft Access legacy', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'accdb', name: 'Access Database', description: 'Microsoft Access 2007+', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'dbf', name: 'dBASE Database', description: 'Legacy dBASE table', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'parquet', name: 'Apache Parquet', description: 'Columnar big data format', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'orc', name: 'Apache ORC', description: 'Optimized row columnar', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'rdb', name: 'Redis Database', description: 'Redis persistence file', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),
    FileFormat(ext: 'sqlite3', name: 'SQLite3 Database', description: 'SQLite3 database file', category: FormatCategory.database, viewer: ViewerType.hex, color: Color(0xFFFD9644), icon: Icons.storage_outlined),

    // ── FONTS ──────────────────────────────────────────────────
    FileFormat(ext: 'ttf', name: 'TrueType Font', description: 'Apple/Microsoft font', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'otf', name: 'OpenType Font', description: 'Cross-platform font', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'ttc', name: 'TrueType Collection', description: 'Multiple fonts in one', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'woff', name: 'Web Font (WOFF)', description: 'Compressed web font v1', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'woff2', name: 'Web Font (WOFF2)', description: 'Brotli-compressed web font', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'eot', name: 'Embedded OpenType', description: 'IE-era web font', category: FormatCategory.fonts, viewer: ViewerType.font, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'fon', name: 'Windows Font', description: 'Legacy Windows raster font', category: FormatCategory.fonts, viewer: ViewerType.hex, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'pfa', name: 'PostScript Font (ASCII)', description: 'Type 1 font text format', category: FormatCategory.fonts, viewer: ViewerType.text, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
    FileFormat(ext: 'pfb', name: 'PostScript Font (Binary)', description: 'Type 1 font binary format', category: FormatCategory.fonts, viewer: ViewerType.hex, color: Color(0xFFA29BFE), icon: Icons.text_fields_outlined),
  ];

  static List<FileFormat> byCategory(FormatCategory cat) =>
      all.where((f) => f.category == cat).toList();

  static FileFormat? byExt(String ext) {
    try {
      return all.firstWhere((f) => f.ext == ext.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  static List<FileFormat> search(String query) {
    final q = query.toLowerCase();
    return all
        .where((f) =>
            f.ext.contains(q) ||
            f.name.toLowerCase().contains(q) ||
            f.description.toLowerCase().contains(q))
        .toList();
  }
}
