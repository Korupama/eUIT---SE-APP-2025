import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Widget hiển thị notification popup khi nhận được từ server
class NotificationOverlay extends StatefulWidget {
  final Widget child;
  final String? mssv;

  const NotificationOverlay({
    super.key,
    required this.child,
    this.mssv,
  });

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  final NotificationService _notificationService = NotificationService();
  final List<StreamSubscription> _subscriptions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
    _connectIfMssv();
  }

  @override
  void didUpdateWidget(NotificationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mssv != widget.mssv) {
      _connectIfMssv();
    }
  }

  void _connectIfMssv() {
    if (widget.mssv != null && widget.mssv!.isNotEmpty) {
      _notificationService.connect(widget.mssv!);
    }
  }

  void _setupNotificationListeners() {
    // Kết quả học tập
    _subscriptions.add(
      _notificationService.onKetQuaHocTap.listen((notification) {
        _showNotification(
          title: 'Cập nhật điểm',
          body: '${notification.tenMonHoc.isNotEmpty ? notification.tenMonHoc : '{Tên môn học}'}\n'
              'QT: ${notification.diemQuaTrinh != null ? notification.diemQuaTrinh : '{Điểm QT}'} | '
              'GK: ${notification.diemGiuaKy != null ? notification.diemGiuaKy : '{Điểm GK}'} | '
              'CK: ${notification.diemCuoiKy != null ? notification.diemCuoiKy : '{Điểm CK}' }',
          color: Colors.blue,
          icon: Icons.grade,
        );
      }),
    );

    // Báo bù
    _subscriptions.add(
      _notificationService.onBaoBu.listen((notification) {
        _showNotification(
          title: 'Lịch học bù',
          body: '${notification.tenMonHoc.isNotEmpty ? notification.tenMonHoc : '{Tên môn học}'}\n'
              'Ngày: ${_formatDate(notification.ngayBu)}\n'
              'Tiết: ${notification.tietBatDau.isNotEmpty ? notification.tietBatDau : '{Tiết bắt ầu}'} - ${notification.tietKetThuc.isNotEmpty ? notification.tietKetThuc : '{Tiết kết thúc}'}\n'
              'Phòng: ${notification.phongHoc.isNotEmpty ? notification.phongHoc : '{Phòng học}'}',
          color: Colors.orange,
          icon: Icons.event,
        );
      }),
    );

    // Báo nghỉ
    _subscriptions.add(
      _notificationService.onBaoNghi.listen((notification) {
        _showNotification(
          title: 'Thông báo nghỉ học',
          body: '${notification.tenMonHoc.isNotEmpty ? notification.tenMonHoc : '{Tên môn học}'}\n'
              'Ngày: ${_formatDate(notification.ngayNghi)}\n'
              'Lý do: ${notification.lyDo.isNotEmpty ? notification.lyDo : '{Lý do}'}',
          color: Colors.red,
          icon: Icons.cancel,
        );
      }),
    );

    // Điểm rèn luyện
    _subscriptions.add(
      _notificationService.onDiemRenLuyen.listen((notification) {
        _showNotification(
          title: 'Điểm rèn luyện',
          body: 'HK${notification.hocKy.isNotEmpty ? notification.hocKy : '{Học kỳ}'} - ${notification.namHoc.isNotEmpty ? notification.namHoc : '{Năm học}'}\n'
              'Điểm: ${notification.diemRenLuyen != null ? notification.diemRenLuyen : '{Điểm rèn luỵện}'}\n'
              'Xếp loại: ${notification.xepLoai.isNotEmpty ? notification.xepLoai : '{Xếp loại}'}',
          color: Colors.green,
          icon: Icons.stars,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showNotification({
    required String title,
    required String body,
    required Color color,
    required IconData icon,
  }) {
    // Remove existing overlay if any
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _NotificationCard(
            title: title,
            body: body,
            color: color,
            icon: icon,
            onDismiss: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _NotificationCard extends StatefulWidget {
  final String title;
  final String body;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: widget.color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onDismiss,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: widget.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.body,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: widget.onDismiss,
                      color: Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget indicator hiển thị trạng thái kết nối SignalR
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return StreamBuilder<bool>(
      stream: notificationService.onConnectionStateChanged,
      initialData: notificationService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: isConnected ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
