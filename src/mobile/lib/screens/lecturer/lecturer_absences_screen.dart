import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerAbsencesScreen - Quản lý vắng mặt
class LecturerAbsencesScreen extends StatefulWidget {
  const LecturerAbsencesScreen({super.key});

  @override
  State<LecturerAbsencesScreen> createState() => _LecturerAbsencesScreenState();
}

class _LecturerAbsencesScreenState extends State<LecturerAbsencesScreen> {
  List<Map<String, dynamic>> _absences = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAbsences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<LecturerProvider>();
      final data = await provider.fetchAbsences();

      if (!mounted) return;

      setState(() {
        _absences = data;
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

  List<Map<String, dynamic>> get _filteredAbsences {
    var filtered = _absences;
    
    // Lọc bỏ các record không có data hợp lệ
    filtered = filtered.where((absence) {
      final mssv = absence['mssv']?.toString() ?? '';
      final hoTen = absence['hoTen']?.toString() ?? '';
      final maMon = absence['maMon']?.toString() ?? '';
      final tenMon = absence['tenMon']?.toString() ?? '';
      
      // Chỉ giữ lại nếu có đủ thông tin
      return mssv.isNotEmpty && 
             hoTen.isNotEmpty && 
             hoTen != 'N/A' && 
             (maMon.isNotEmpty || (tenMon.isNotEmpty && tenMon != 'N/A'));
    }).toList();
    
    // Lọc theo search query
    if (_searchQuery.isEmpty) return filtered;
    return filtered.where((absence) {
      final hoTen = (absence['hoTen']?.toString() ?? '').toLowerCase();
      final mssv = (absence['mssv']?.toString() ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return hoTen.contains(query) || mssv.contains(query);
    }).toList();
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
                _buildSearchBar(isDark),
                Expanded(
                  child: _isLoading
                      ? _buildShimmerLoading(isDark)
                      : _buildAbsencesList(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAbsenceDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('Báo nghỉ'),
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
              Icons.event_busy_rounded,
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
                  'Quản lý vắng mặt',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${_absences.length} sinh viên',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAbsences,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên hoặc MSSV...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor:
              (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildAbsencesList(bool isDark) {
    if (_filteredAbsences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy kết quả'
                  : 'Không có sinh viên vắng mặt',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAbsences,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _filteredAbsences.length,
        itemBuilder: (context, index) {
          final absence = _filteredAbsences[index];
          return _buildAbsenceCard(absence, isDark);
        },
      ),
    );
  }

  Widget _buildAbsenceCard(Map<String, dynamic> absence, bool isDark) {
    final mssv = absence['mssv']?.toString() ?? '';
    final hoTen = absence['hoTen']?.toString() ?? 'N/A';
    final maMon = absence['maMon']?.toString() ?? '';
    final tenMon = absence['tenMon']?.toString() ?? 'N/A';
    final soTietVang = absence['soTietVang'] is int 
        ? absence['soTietVang'] as int 
        : int.tryParse(absence['soTietVang']?.toString() ?? '0') ?? 0;
    final soTietCoPhep = absence['soTietCoPhep'] is int
        ? absence['soTietCoPhep'] as int
        : int.tryParse(absence['soTietCoPhep']?.toString() ?? '0') ?? 0;
    final soTietKhongPhep = soTietVang - soTietCoPhep;
    final tongSoTiet = absence['tongSoTiet'] is int
        ? absence['tongSoTiet'] as int
        : int.tryParse(absence['tongSoTiet']?.toString() ?? '45') ?? 45;

    // Không hiển thị card nếu thiếu thông tin quan trọng
    if (mssv.isEmpty || hoTen == 'N/A' || (tenMon == 'N/A' && maMon.isEmpty)) {
      return const SizedBox.shrink();
    }

    final tiLeVang = tongSoTiet > 0 ? (soTietVang / tongSoTiet * 100) : 0.0;

    final isWarning = tiLeVang > 20; // Cảnh báo nếu vắng > 20%

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? Colors.red.withOpacity(0.5)
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isWarning
                            ? const LinearGradient(
                                colors: [Colors.red, Colors.orange],
                              )
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$soTietVang',
                          style: AppTheme.headingMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hoTen,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MSSV: $mssv',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWarning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cảnh báo',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Môn học',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '$tenMon ($maMon)',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Có phép',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '$soTietCoPhep tiết',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Không phép',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '$soTietKhongPhep tiết',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tỷ lệ vắng',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${tiLeVang.toStringAsFixed(1)}%',
                            style: AppTheme.bodySmall.copyWith(
                              color: isWarning ? Colors.red : Colors.green,
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

  void _showCreateAbsenceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<LecturerProvider>();
    
    // Get classes list
    final classes = provider.teachingClasses;
    
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lớp học để báo nghỉ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedClass;
    DateTime selectedDate = DateTime.now();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
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
                              Icons.event_busy,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Đăng ký báo nghỉ',
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
                        'Ngày nghỉ:',
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
                          hintText: 'Nhập lý do nghỉ...',
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
                          onPressed: selectedClass == null
                              ? null
                              : () async {
                                  final success = await provider.createAbsence(
                                    maLop: selectedClass!,
                                    ngayNghi: selectedDate,
                                    lyDo: reasonController.text.trim(),
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Đã đăng ký báo nghỉ thành công'
                                            : 'Lỗi khi đăng ký báo nghỉ',
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
                                    _loadAbsences();
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
            height: 180,
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
