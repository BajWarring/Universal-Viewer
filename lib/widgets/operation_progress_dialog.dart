import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OperationProgressDialog extends StatefulWidget {
  final String title;
  final Future<void> Function(Function(double progress, String currentFile) update) operation;

  const OperationProgressDialog({super.key, required this.title, required this.operation});

  @override
  State<OperationProgressDialog> createState() => _OperationProgressDialogState();
}

class _OperationProgressDialogState extends State<OperationProgressDialog> {
  double _progress = 0.0;
  String _currentFile = "Preparing...";
  bool _keepScreenOn = true;
  bool _isCancelled = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    WakelockPlus.enable();
    _runOperation();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _runOperation() async {
    try {
      await widget.operation((progress, fileName) {
        if (_isCancelled) throw Exception("Cancelled by user");
        if (mounted) setState(() { _progress = progress; _currentFile = fileName; });
        _showNotification(progress, fileName);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation stopped: $e')));
      }
    } finally {
      if (_keepScreenOn) WakelockPlus.disable();
      flutterLocalNotificationsPlugin.cancel(0); // Clear notification
      if (mounted) Navigator.pop(context);
    }
  }

  void _showNotification(double progress, String filename) async {
    int progressInt = (progress * 100).toInt();
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'op_channel', 'File Operations',
      channelDescription: 'Shows progress of background file operations',
      importance: Importance.low, priority: Priority.low,
      showProgress: true, maxProgress: 100, progress: progressInt,
      ongoing: true, onlyAlertOnce: true,
      actions: [const AndroidNotificationAction('cancel_id', 'Cancel')],
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, widget.title, filename, platformChannelSpecifics);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: _progress, color: primaryColor, backgroundColor: Colors.grey.withOpacity(0.2), minHeight: 6, borderRadius: BorderRadius.circular(3)),
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
              SizedBox(width: 24, height: 24, child: Checkbox(value: _keepScreenOn, activeColor: primaryColor, onChanged: (v) { setState(() => _keepScreenOn = v!); if (v == true) WakelockPlus.enable(); else WakelockPlus.disable(); })),
              const SizedBox(width: 8),
              const Text('Keep screen turned on', style: TextStyle(fontSize: 13)),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation running in background... Check notification panel.')));
            Navigator.pop(context);
          },
          child: Text('Hide', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () { setState(() => _isCancelled = true); },
          child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
