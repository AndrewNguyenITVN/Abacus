import 'package:flutter/material.dart';
import '../../../services/notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  final NotificationService _notificationService = NotificationService();
  
  bool _isLoading = true;
  int _threshold = 70;
  bool _enabled = true;
  bool _savingsGoalEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final threshold = await _notificationService.getThreshold();
    final enabled = await _notificationService.isEnabled();
    final savingsGoalEnabled = await _notificationService.isSavingsGoalEnabled();

    if (mounted) {
      setState(() {
        _threshold = threshold;
        _enabled = enabled;
        _savingsGoalEnabled = savingsGoalEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _notificationService.setThreshold(_threshold);
    await _notificationService.setEnabled(_enabled);
    await _notificationService.setSavingsGoalEnabled(_savingsGoalEnabled);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã lưu cài đặt thông báo'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cài đặt thông báo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle savings goal alerts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.savings_rounded, size: 18, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Đạt mục tiêu tiết kiệm',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thông báo khi đạt 100% mục tiêu',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _savingsGoalEnabled,
                    onChanged: (v) {
                      setState(() {
                        _savingsGoalEnabled = v;
                      });
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Toggle spending alerts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_rounded, size: 18, color: Color(0xFFFF9800)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Cảnh báo chi tiêu',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nhận thông báo khi vượt ngưỡng',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (v) {
                      setState(() {
                        _enabled = v;
                      });
                    },
                    activeColor: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          
            // Threshold slider
            Text(
              'Ngưỡng cảnh báo: $_threshold%',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cảnh báo lặp lại mỗi +5% sau khi vượt ngưỡng',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFFF9800),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: const Color(0xFFFF9800),
                overlayColor: const Color(0xFFFF9800).withOpacity(0.2),
                valueIndicatorColor: const Color(0xFFFF9800),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Slider(
                value: _threshold.toDouble(),
                min: 50,
                max: 100,
                divisions: 10,
                label: '$_threshold%',
                onChanged: _enabled
                    ? (v) {
                        setState(() {
                          _threshold = v.round();
                        });
                      }
                    : null,
              ),
            ),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ví dụ: Ngưỡng 70% → báo ở 70%, 75%, 80%, 85%...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

