import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

/// LecturerMakeupClassesScreen - Quản lý lớp học bù
class LecturerMakeupClassesScreen extends StatefulWidget {
  const LecturerMakeupClassesScreen({super.key});

  @override
  State<LecturerMakeupClassesScreen> createState() =>
      _LecturerMakeupClassesScreenState();
}

class _LecturerMakeupClassesScreenState
    extends State<LecturerMakeupClassesScreen> {
  List<Map<String, dynamic>> _makeupClasses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMakeupClasses();
  }

  Future<void> _loadMakeupClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<LecturerProvider>();
      final data = await provider.fetchMakeupClasses();

      if (!mounted) return;

      setState(() {
        _makeupClasses = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: _isLoading
                      ? _buildShimmerLoading(isDark)
                      : _buildMakeupClassesList(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                .withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch học bù',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${_makeupClasses.length} lớp học bù',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMakeupClasses,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildMakeupClassesList(bool isDark) {
    if (_makeupClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có lịch học bù',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMakeupClasses,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _makeupClasses.length,
        itemBuilder: (context, index) {
          final makeupClass = _makeupClasses[index];
          return _buildMakeupClassCard(makeupClass, isDark);
        },
      ),
    );
  }

  Widget _buildMakeupClassCard(Map<String, dynamic> makeupClass, bool isDark) {
    final maMon = makeupClass['maMon']?.toString() ?? '';
    final tenMon = makeupClass['tenMon']?.toString() ?? 'N/A';
    final nhom = makeupClass['nhom']?.toString() ?? '';
    final ngayHocBu = makeupClass['ngayHocBu']?.toString();
    final tietBatDau = makeupClass['tietBatDau']?.toString() ?? '';
    final tietKetThuc = makeupClass['tietKetThuc']?.toString() ?? '';
    final phong = makeupClass['phong']?.toString() ?? 'TBA';
    final lyDo = makeupClass['lyDo']?.toString() ?? '';
    final trangThai = makeupClass['trangThai']?.toString() ?? 'Chưa học';

    // Không hiển thị nếu thiếu thông tin quan trọng
    if (maMon.isEmpty || tenMon == 'N/A' || ngayHocBu == null || ngayHocBu.isEmpty) {
      return const SizedBox.shrink();
    }

    DateTime? dateTime;
    if (ngayHocBu != null) {
      dateTime = DateTime.tryParse(ngayHocBu);
    }
    
    // Nếu không parse được ngày thì không hiển thị
    if (dateTime == null) {
      return const SizedBox.shrink();
    }

    final isPast = dateTime != null && dateTime.isBefore(DateTime.now());
    final isToday = dateTime != null &&
        dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? Colors.orange.withOpacity(0.5)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                  .withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: isToday
                            ? const LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              )
                            : isPast
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.shade600,
                                      Colors.grey.shade400
                                    ],
                                  )
                                : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateTime != null
                                ? DateFormat('dd').format(dateTime)
                                : '??',
                            style: AppTheme.headingMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateTime != null
                                ? DateFormat('MMM').format(dateTime)
                                : '',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenMon,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$maMon - Nhóm $nhom',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hôm nay',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.access_time,
                        'Tiết $tietBatDau - $tietKetThuc',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.room, 'Phòng $phong', isDark),
                      if (lyDo.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.info_outline, lyDo, isDark),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 16,
                            color: _getStatusColor(trangThai),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trangThai,
                            style: AppTheme.bodySmall.copyWith(
                              color: _getStatusColor(trangThai),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã học':
      case 'completed':
        return Colors.green;
      case 'đang học':
      case 'in_progress':
        return Colors.blue;
      case 'chưa học':
      case 'pending':
        return Colors.orange;
      case 'đã hủy':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            height: 160,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
