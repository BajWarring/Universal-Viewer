import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompressModal extends StatefulWidget {
  final String itemName;
  final Color primaryColor;
  final Function(String archiveName, String format, String? password) onCompress;

  const CompressModal({
    super.key,
    required this.itemName,
    required this.primaryColor,
    required this.onCompress,
  });

  @override
  State<CompressModal> createState() => _CompressModalState();
}

class _CompressModalState extends State<CompressModal> {
  late TextEditingController _nameCtrl;
  final TextEditingController _pwdCtrl = TextEditingController();
  String _format = '.zip';
  String _encryption = 'None';
  bool _deleteSource = false;
  bool _showPwd = false;

  @override
  void initState() {
    super.initState();
    final baseName = widget.itemName.contains('.')
        ? widget.itemName.substring(0, widget.itemName.lastIndexOf('.'))
        : widget.itemName;
    _nameCtrl = TextEditingController(text: '$baseName.zip');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('New Archive',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _label('Archive Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration('e.g. archive.zip', isDark),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Format'),
                      const SizedBox(height: 6),
                      _dropdown(['.zip', '.7z', '.tar'], _format, (v) {
                        setState(() => _format = v!);
                        final base = _nameCtrl.text.contains('.')
                            ? _nameCtrl.text.substring(0, _nameCtrl.text.lastIndexOf('.'))
                            : _nameCtrl.text;
                        _nameCtrl.text = '$base$v';
                      }, isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Encryption'),
                      const SizedBox(height: 6),
                      _dropdown(['None', 'AES-256'], _encryption, (v) => setState(() => _encryption = v!), isDark),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Password (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _pwdCtrl,
              obscureText: !_showPwd,
              decoration: _inputDecoration('Optional', isDark).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_showPwd ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                  onPressed: () => setState(() => _showPwd = !_showPwd),
                ),
              ),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _deleteSource,
                  onChanged: (v) => setState(() => _deleteSource = v!),
                  activeColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Delete source after compression',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => widget.onCompress(
                  _nameCtrl.text.trim(),
                  _format,
                  _pwdCtrl.text.isEmpty ? null : _pwdCtrl.text,
                ),
                child: Text('Create Archive', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      letterSpacing: 1.2, color: Colors.grey.shade600,
    ),
  );

  InputDecoration _inputDecoration(String hint, bool isDark) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _dropdown(List<String> items, String value, ValueChanged<String?> onChanged, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChanged,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
