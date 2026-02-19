import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';

class SvgViewer extends StatefulWidget {
  final String filePath;
  const SvgViewer({super.key, required this.filePath});

  @override
  State<SvgViewer> createState() => _SvgViewerState();
}

class _SvgViewerState extends State<SvgViewer> {
  bool _darkBackground = true;
  bool _showCode = false;
  String? _svgCode;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    try {
      final code = await File(widget.filePath).readAsString();
      if (mounted) setState(() => _svgCode = code);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          color: const Color(0xFF14141F),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _ToolBtn(
                label: _darkBackground ? 'Dark BG' : 'Light BG',
                icon: Icons.contrast,
                onTap: () => setState(() => _darkBackground = !_darkBackground),
              ),
              const SizedBox(width: 8),
              _ToolBtn(
                label: _showCode ? 'View SVG' : 'View XML',
                icon: _showCode ? Icons.image_outlined : Icons.code,
                onTap: () => setState(() => _showCode = !_showCode),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showCode
              ? _buildCodeView()
              : _buildSvgView(),
        ),
      ],
    );
  }

  Widget _buildSvgView() {
    return Container(
      color: _darkBackground ? Colors.black : Colors.white,
      child: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 10,
          child: SvgPicture.file(
            File(widget.filePath),
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const CircularProgressIndicator(color: Color(0xFF00E5FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _svgCode ?? 'Loading...',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF00E5FF),
          height: 1.7,
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ToolBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF00E5FF)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF00E5FF), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
