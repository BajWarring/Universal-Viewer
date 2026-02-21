import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../filesystem/domain/entities/omni_node.dart';
import '../../application/archive_service.dart';

class CompressDialog extends ConsumerStatefulWidget {
  final OmniNode sourceNode;

  const CompressDialog({super.key, required this.sourceNode});

  static void show(BuildContext context, OmniNode node) {
    showDialog(
      context: context,
      builder: (context) => CompressDialog(sourceNode: node),
    );
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

  @override
  void initState() {
    super.initState();
    // Pre-fill the archive name just like your JS logic: 
    // (itemName.includes('.') ? itemName.substring(...) : itemName) + ".zip"
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
    
    // In a production scenario, you would grab the parent directory path
    final destPath = '${widget.sourceNode.path}_compressed$_selectedFormat';
    
    final service = ArchiveService();
final params = CompressParams(
  sourcePath: widget.sourceNode.path,
  destinationPath: destPath,
  format: _selectedFormat,
  // password: _passwordController.text, // Add this field to CompressParams if needed
);
await service.compressDirectory(params);
    if (_deleteSource) {
        // Trigger delete logic from your fileOpProvider
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archive Created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Archive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Archive Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Archive Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),

            // Format & Encryption Grid
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: const InputDecoration(
                      labelText: 'Format',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    items: ['.zip', '.7z', '.tar'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedFormat = newValue!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEncryption,
                    decoration: const InputDecoration(
                      labelText: 'Encryption',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    items: ['None', 'AES-256'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedEncryption = newValue!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Password Input
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
            const SizedBox(height: 16),

            // Delete Source Checkbox
            CheckboxListTile(
              title: const Text('Delete source after compression', style: TextStyle(fontSize: 14)),
              value: _deleteSource,
              onChanged: (bool? value) => setState(() => _deleteSource = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Action Button
            FilledButton(
              onPressed: _isProcessing ? null : _startCompression,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
