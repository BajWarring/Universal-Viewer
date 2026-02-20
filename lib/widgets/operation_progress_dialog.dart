import 'package:flutter/material.dart';

class OperationProgressDialog extends StatefulWidget {
  final String operationName; // e.g., "Compressing" or "Extracting"
  final String fileName;

  const OperationProgressDialog({super.key, required this.operationName, required this.fileName});

  @override
  State<OperationProgressDialog> createState() => _OperationProgressDialogState();
}

class _OperationProgressDialogState extends State<OperationProgressDialog> {
  double _progress = 0.35; // Mock progress
  String _currentFile = "Preparing...";
  bool _keepScreenOn = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.operationName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(_currentFile, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
              Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(value: _keepScreenOn, onChanged: (v) => setState(() => _keepScreenOn = v!)),
              ),
              const SizedBox(width: 8),
              const Text('Keep screen turned on', style: TextStyle(fontSize: 13)),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Push Notification logic goes here
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation running in background...')));
          },
          child: const Text('Hide'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
