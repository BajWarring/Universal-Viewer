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

  // PHASE 1 FIX: instance-level service
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

    // PHASE 1 FIX: using named params + password field
    final params = CompressParams(
      sourcePath: widget.sourceNode.path,
      destinationPath: destPath,
      format: _selectedFormat,
      password: _passwordController.text.isEmpty ? null : _passwordController.text,
    );

    try {
      await _archiveService.compressDirectory(params);
      if (_deleteSource) {
        // TODO: trigger delete via provider
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archive Created!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('New Archive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Archive Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFormat,
                  decoration: const InputDecoration(labelText: 'Format', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  items: ['.zip', '.7z', '.tar'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _selectedFormat = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEncryption,
                  decoration: const InputDecoration(labelText: 'Encryption', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  items: ['None', 'AES-256'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _selectedEncryption = v!),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: 'Password (Optional)',
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Delete source after compression', style: TextStyle(fontSize: 14)),
              value: _deleteSource,
              onChanged: (v) => setState(() => _deleteSource = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _isProcessing ? null : _startCompression,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isProcessing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Archive', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
