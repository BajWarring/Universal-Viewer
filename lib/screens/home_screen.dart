import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/format_registry.dart';
import '../widgets/category_card.dart';
import '../widgets/format_search_delegate.dart';
import 'viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = -1;

  final List<_CategoryInfo> _categories = [
    _CategoryInfo('Documents', FormatCategory.documents, Icons.description_outlined, Color(0xFF6C63FF), '29 formats'),
    _CategoryInfo('Images', FormatCategory.images, Icons.image_outlined, Color(0xFF00E5FF), '21 formats'),
    _CategoryInfo('Video', FormatCategory.video, Icons.videocam_outlined, Color(0xFFFF6B9D), '15 formats'),
    _CategoryInfo('Archives', FormatCategory.archives, Icons.folder_zip_outlined, Color(0xFFF7B731), '12 formats'),
    _CategoryInfo('Code', FormatCategory.code, Icons.code, Color(0xFF26DE81), '24 formats'),
    _CategoryInfo('Database', FormatCategory.database, Icons.storage_outlined, Color(0xFFFD9644), '11 formats'),
    _CategoryInfo('Fonts', FormatCategory.fonts, Icons.text_fields_outlined, Color(0xFFA29BFE), '9 formats'),
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty && mounted) {
      final file = result.files.first;
      final ext = file.extension ?? '';
      final format = FormatRegistry.byExt(ext);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(
            filePath: file.path!,
            fileName: file.name,
            fileSize: file.size,
            format: format,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOpenFileButton(),
                const SizedBox(height: 28),
                _buildSectionTitle('Browse by Category'),
                const SizedBox(height: 12),
                _buildCategoryGrid(),
                const SizedBox(height: 28),
                _buildSectionTitle('All Formats'),
                const SizedBox(height: 12),
                _buildAllFormatsGrid(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
          ).createShader(bounds),
          child: const Text(
            'OmniView',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0D14), Color(0xFF0D0D14)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => showSearch(
            context: context,
            delegate: FormatSearchDelegate(),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOpenFileButton() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.2),
              const Color(0xFF00E5FF).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.folder_open_rounded, color: Color(0xFF6C63FF), size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Open Any File', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('120+ formats supported', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF6C63FF).withOpacity(0.7), size: 18),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _categories.length,
      itemBuilder: (ctx, i) => CategoryCard(
        info: _categories[i],
        delay: i * 60,
        onTap: () => _showCategorySheet(_categories[i]),
      ),
    );
  }

  Widget _buildAllFormatsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FormatRegistry.all
          .asMap()
          .entries
          .map((e) => _FormatChip(format: e.value, delay: e.key * 10))
          .toList(),
    );
  }

  void _showCategorySheet(_CategoryInfo info) {
    final formats = FormatRegistry.byCategory(info.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySheet(info: info, formats: formats, onFilePick: _pickFile),
    );
  }
}

class _CategoryInfo {
  final String name;
  final FormatCategory category;
  final IconData icon;
  final Color color;
  final String count;
  _CategoryInfo(this.name, this.category, this.icon, this.color, this.count);
}

class _FormatChip extends StatelessWidget {
  final FileFormat format;
  final int delay;
  const _FormatChip({required this.format, required this.delay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormatInfoScreen(format: format),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: format.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: format.color.withOpacity(0.25), width: 1),
        ),
        child: Text(
          '.${format.ext}',
          style: TextStyle(
            color: format.color,
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  final _CategoryInfo info;
  final List<FileFormat> formats;
  final VoidCallback onFilePick;
  const _CategorySheet({required this.info, required this.formats, required this.onFilePick});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF14141F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E1E30), width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(info.icon, color: info.color, size: 24),
                  const SizedBox(width: 10),
                  Text(info.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: info.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(info.count, style: TextStyle(color: info.color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: formats.length,
                itemBuilder: (_, i) => _FormatListTile(format: formats[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatListTile extends StatelessWidget {
  final FileFormat format;
  const _FormatListTile({required this.format});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormatInfoScreen(format: format))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E30), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: format.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '.${format.ext.toUpperCase()}',
                  style: TextStyle(color: format.color, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(format.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(format.description, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class FormatInfoScreen extends StatelessWidget {
  final FileFormat format;
  const FormatInfoScreen({super.key, required this.format});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('.${format.ext.toUpperCase()} — ${format.name}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: format.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: format.color.withOpacity(0.3), width: 1),
              ),
              child: Column(
                children: [
                  Icon(format.icon, color: format.color, size: 56),
                  const SizedBox(height: 12),
                  Text('.${format.ext.toUpperCase()}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: format.color, fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  Text(format.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(format.description, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _InfoRow(label: 'Category', value: format.category.name.toUpperCase()),
            _InfoRow(label: 'Viewer', value: format.viewer.name.toUpperCase()),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14141F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E30)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
