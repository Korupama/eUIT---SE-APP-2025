import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

      print('=== MAKEUP CLASSES DEBUG ===');
      print('Total received: ${data.length}');
      if (data.isNotEmpty) {
        print('First item keys: ${data.first.keys.toList()}');
        print('First item full data: ${data.first}');
        print('TenMonHoc (PascalCase): ${data.first['TenMonHoc']}');
        print('MaLop (PascalCase): ${data.first['MaLop']}');
        print('NgayHocBu (PascalCase): ${data.first['NgayHocBu']}');
      }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMakeupClassDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('Học bù'),
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
    // Backend trả về PascalCase, cần map đúng field names
    final maMon = makeupClass['MaLop']?.toString() ?? 
                  makeupClass['maMon']?.toString() ?? 
                  makeupClass['maLop']?.toString() ?? '';
    final tenMon = makeupClass['TenMonHoc']?.toString() ?? 
                   makeupClass['tenMon']?.toString() ?? 
                   makeupClass['tenMonHoc']?.toString() ?? 
                   makeupClass['tenLop']?.toString() ?? 
                   'Chưa có tên';
    final nhom = makeupClass['Nhom']?.toString() ?? 
                 makeupClass['nhom']?.toString() ?? '';
    final ngayHocBu = makeupClass['NgayHocBu']?.toString() ?? 
                      makeupClass['ngayHocBu']?.toString();
    final tietBatDau = makeupClass['TietBatDau']?.toString() ?? 
                       makeupClass['tietBatDau']?.toString() ?? '';
    final tietKetThuc = makeupClass['TietKetThuc']?.toString() ?? 
                        makeupClass['tietKetThuc']?.toString() ?? '';
    final phong = makeupClass['PhongHoc']?.toString() ?? 
                  makeupClass['phong']?.toString() ?? 
                  makeupClass['phongHoc']?.toString() ?? 
                  'TBA';
    final lyDo = makeupClass['LyDo']?.toString() ?? 
                 makeupClass['lyDo']?.toString() ?? '';
    final trangThai = makeupClass['TinhTrang']?.toString() ?? 
                      makeupClass['trangThai']?.toString() ?? 
                      'Chưa học';

    // Parse date - hỗ trợ nhiều format
    DateTime? dateTime;
    if (ngayHocBu != null && ngayHocBu.isNotEmpty) {
      dateTime = DateTime.tryParse(ngayHocBu);
      // Nếu parse thất bại, thử format dd/MM/yyyy
      if (dateTime == null) {
        try {
          final parts = ngayHocBu.split('/');
          if (parts.length == 3) {
            dateTime = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (e) {
          // Keep dateTime as null
        }
      }
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
                                : '--',
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
                            maMon.isNotEmpty
                                ? (nhom.isNotEmpty ? '$maMon - Nhóm $nhom' : maMon)
                                : (nhom.isNotEmpty ? 'Nhóm $nhom' : 'Chưa có mã lớp'),
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

  void _showCreateMakeupClassDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<LecturerProvider>();
    
    // Get classes list
    final classes = provider.teachingClasses;
    
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lớp học để đăng ký học bù'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedClass;
    DateTime selectedDate = DateTime.now();
    int? startPeriod;
    int? endPeriod;
    final roomController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
                      : [Colors.white, const Color(0xFFE3F2FD)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.7),
                          isDark
                              ? Colors.white.withOpacity(0.02)
                              : Colors.white.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event_repeat,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Đăng ký học bù',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Class dropdown
                        Text(
                          'Chọn lớp:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0A0E21).withOpacity(0.5)
                                : const Color(0xFFF5F7FA).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedClass,
                              isExpanded: true,
                              hint: Text(
                                'Chọn lớp học',
                                style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              dropdownColor: isDark
                                  ? const Color(0xFF1E2746)
                                  : Colors.white,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              items: classes.map((cls) {
                                return DropdownMenuItem<String>(
                                  value: cls.maLop,
                                  child: Text('${cls.maMon} - ${cls.tenMon} (${cls.nhom})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClass = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date picker
                        Text(
                          'Ngày học bù:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0A0E21).withOpacity(0.5)
                                  : const Color(0xFFF5F7FA).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Period selection
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tiết bắt đầu:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0A0E21).withOpacity(0.5)
                                          : const Color(0xFFF5F7FA).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: startPeriod,
                                        isExpanded: true,
                                        hint: Text(
                                          'Tiết',
                                          style: TextStyle(
                                            color: isDark ? Colors.white38 : Colors.black38,
                                          ),
                                        ),
                                        dropdownColor: isDark
                                            ? const Color(0xFF1E2746)
                                            : Colors.white,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        items: List.generate(10, (i) => i + 1).map((period) {
                                          return DropdownMenuItem(
                                            value: period,
                                            child: Text('Tiết $period'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            startPeriod = value;
                                          });
                                        },
                                      ),
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
                                    'Tiết kết thúc:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0A0E21).withOpacity(0.5)
                                          : const Color(0xFFF5F7FA).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: endPeriod,
                                        isExpanded: true,
                                        hint: Text(
                                          'Tiết',
                                          style: TextStyle(
                                            color: isDark ? Colors.white38 : Colors.black38,
                                          ),
                                        ),
                                        dropdownColor: isDark
                                            ? const Color(0xFF1E2746)
                                            : Colors.white,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        items: List.generate(10, (i) => i + 1).map((period) {
                                          return DropdownMenuItem(
                                            value: period,
                                            child: Text('Tiết $period'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            endPeriod = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Room
                        Text(
                          'Phòng học:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: roomController,
                          decoration: InputDecoration(
                            hintText: 'Nhập phòng học...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0A0E21).withOpacity(0.5)
                                : const Color(0xFFF5F7FA).withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Reason
                        Text(
                          'Lý do:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Nhập lý do học bù...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0A0E21).withOpacity(0.5)
                                : const Color(0xFFF5F7FA).withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedClass == null ||
                                    startPeriod == null ||
                                    endPeriod == null
                                ? null
                                : () async {
                                    if (startPeriod! >= endPeriod!) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tiết kết thúc phải sau tiết bắt đầu'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await provider.createMakeupClass(
                                      maLop: selectedClass!,
                                      ngayHocBu: selectedDate,
                                      tietBatDau: startPeriod!,
                                      tietKetThuc: endPeriod!,
                                      phongHoc: roomController.text.trim(),
                                      lyDo: reasonController.text.trim(),
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Đã đăng ký học bù thành công'
                                              : 'Lỗi khi đăng ký học bù',
                                        ),
                                        backgroundColor:
                                            success ? Colors.green : Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );

                                    if (success) {
                                      _loadMakeupClasses();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Xác nhận đăng ký',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
