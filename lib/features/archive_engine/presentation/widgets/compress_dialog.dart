import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../application/archive_service.dart';

class CompressDialog extends ConsumerStatefulWidget {
  final OmniNode sourceNode;
  const CompressDialog({super.key, required this.sourceNode});

  static void show(BuildContext context, OmniNode node) {
    showDialog(context: context, builder: (context) => CompressDialog(sourceNode: node));
  }

  @override
  ConsumerState<CompressDialog> createState() => _CompressDialogState();
}

class _CompressDialogState extends ConsumerState<CompressDialog> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  String _selectedFormat = '.zip';
  String _selectedEncryption = 'None';
  bool _deleteSource = false;
  bool _isObscured = true;
  bool _isProcessing = false;
  final _archiveService = ArchiveService();

  @override
  void initState() {
    super.initState();
    final baseName = widget.sourceNode.name.split('.').first;
    _nameController = TextEditingController(text: '$baseName.zip');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _startCompression() async {
    setState(() => _isProcessing = true);
    final destPath = '${widget.sourceNode.path}_compressed$_selectedFormat';
    final params = CompressParams(
      sourcePath: widget.sourceNode.path,
      destinationPath: destPath,
      format: _selectedFormat.replaceAll('.', ''),
      password: _passwordController.text.isEmpty ? null : _passwordController.text,
    );
    try {
      await _archiveService.compressDirectory(params);
      if (_deleteSource) {}
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archive Created!')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Archive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Text('ARCHIVE NAME', style: labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FORMAT', style: labelStyle),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedFormat,
                        decoration: InputDecoration(filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        items: ['.zip', '.7z', '.tar'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (v) => setState(() => _selectedFormat = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ENCRYPTION', style: labelStyle),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedEncryption,
                        decoration: InputDecoration(filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        items: ['None', 'AES-256', 'ZipCrypto'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (v) => setState(() => _selectedEncryption = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('PASSWORD', style: labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                hintText: 'Optional',
                filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(icon: Icon(_isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded), onPressed: () => setState(() => _isObscured = !_isObscured)),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Delete source after compression', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              value: _deleteSource,
              onChanged: (v) => setState(() => _deleteSource = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isProcessing ? null : _startCompression,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isProcessing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Archive', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
