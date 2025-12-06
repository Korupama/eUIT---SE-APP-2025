import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/teaching_class.dart';
import '../../models/class_student.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerGradeManagementScreen - Quản lý điểm số
class LecturerGradeManagementScreen extends StatefulWidget {
  const LecturerGradeManagementScreen({super.key});

  @override
  State<LecturerGradeManagementScreen> createState() =>
      _LecturerGradeManagementScreenState();
}

class _LecturerGradeManagementScreenState
    extends State<LecturerGradeManagementScreen> {
  TeachingClass? _selectedClass;
  String _selectedGradeType = 'all'; // all, TX, GK, CK
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ClassStudent> _students = [];
  bool _isLoading = false;
  bool _isEditing = false;
  final Map<String, Map<String, double?>> _gradeChanges = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch classes for current academic year (2025-2026), all semesters
      context.read<LecturerProvider>().fetchTeachingClassesForYear('2025-2026');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API to get grades for selected class
      final provider = context.read<LecturerProvider>();
      final gradesData = await provider.fetchGrades(
        courseId: _selectedClass!.maMon,
      );

      if (!mounted) return;

      setState(() {
        _students = gradesData.map((data) {
          return ClassStudent(
            mssv: data['mssv']?.toString() ?? '',
            hoTen: data['hoTen'] as String? ?? '',
            ngaySinh: data['ngaySinh'] != null
                ? DateTime.tryParse(data['ngaySinh'] as String)
                : null,
            email: data['email'] as String?,
            gioiTinh: data['gioiTinh'] as String?,
            lopSinhHoat: data['lopSinhHoat'] as String?,
            diemThuongXuyen: data['diemQuaTrinh'] != null
                ? (data['diemQuaTrinh'] as num).toDouble()
                : null,
            diemGiuaKy: data['diemGiuaKy'] != null
                ? (data['diemGiuaKy'] as num).toDouble()
                : null,
            diemCuoiKy: data['diemCuoiKy'] != null
                ? (data['diemCuoiKy'] as num).toDouble()
                : null,
            diemTongKet: data['diemTongKet'] != null
                ? (data['diemTongKet'] as num).toDouble()
                : null,
            soTietVang: data['soTietVang'] as int?,
            trangThai: data['trangThai'] as String?,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải danh sách sinh viên: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                if (_selectedClass != null) _buildGradeTypeFilter(isDark),
                Expanded(
                  child: _selectedClass == null
                      ? _buildClassSelection(provider, isDark)
                      : _isLoading
                      ? _buildShimmerLoading(isDark)
                      : _buildGradeTable(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedClass != null && _isEditing
          ? _buildSaveButton(isDark)
          : null,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_selectedClass != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedClass = null;
                      _students = [];
                      _isEditing = false;
                      _gradeChanges.clear();
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                )
              else
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
                  Icons.grade_rounded,
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
                      _selectedClass == null
                          ? 'Quản lý điểm'
                          : _selectedClass!.tenMon,
                      style: AppTheme.headingMedium.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _selectedClass == null
                          ? 'Chọn lớp để nhập điểm'
                          : 'Nhóm ${_selectedClass!.nhom} • ${_selectedClass!.siSo} sinh viên',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedClass != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                        break;
                      case 'import':
                        _showImportDialog();
                        break;
                      case 'export':
                        _showExportDialog();
                        break;
                      case 'stats':
                        _showStatsDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            _isEditing ? Icons.check : Icons.edit,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 12),
                          Text(_isEditing ? 'Xong' : 'Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.upload_file, size: 20),
                          SizedBox(width: 12),
                          Text('Import Excel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 12),
                          Text('Export Excel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'stats',
                      child: Row(
                        children: [
                          Icon(Icons.analytics, size: 20),
                          SizedBox(width: 12),
                          Text('Thống kê'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_selectedClass != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sinh viên...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeTypeFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', 'all', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Thường xuyên', 'TX', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Giữa kỳ', 'GK', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Cuối kỳ', 'CK', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Tổng kết', 'TK', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedGradeType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGradeType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelection(LecturerProvider provider, bool isDark) {
    if (provider.isLoading) {
      return _buildShimmerLoading(isDark);
    }

    if (provider.teachingClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.class_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có lớp giảng dạy',
              style: AppTheme.headingMedium.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa được phân công lớp nào',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.teachingClasses.length,
      itemBuilder: (context, index) {
        final teachingClass = provider.teachingClasses[index];
        return _buildClassCard(teachingClass, isDark);
      },
    );
  }

  Widget _buildClassCard(TeachingClass teachingClass, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedClass = teachingClass;
                _loadStudents();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.class_outlined,
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
                          teachingClass.tenMon,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              teachingClass.maMon,
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Nhóm ${teachingClass.nhom}',
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${teachingClass.siSo} SV',
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeTable(bool isDark) {
    final filteredStudents = _students.where((student) {
      if (_searchQuery.isEmpty) return true;
      return student.hoTen.toLowerCase().contains(_searchQuery) ||
          student.mssv.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentGradeCard(student, index + 1, isDark);
      },
    );
  }

  Widget _buildStudentGradeCard(ClassStudent student, int stt, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                0.5,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: student.isAtRisk
                    ? Colors.red.withOpacity(0.5)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                          .withOpacity(0.3),
                width: student.isAtRisk ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: student.isAtRisk
                        ? LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.2),
                              Colors.orange.withOpacity(0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100)
                                  .withOpacity(0.5),
                              (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100)
                                  .withOpacity(0.3),
                            ],
                          ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            student.initials,
                            style: AppTheme.bodyMedium.copyWith(
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
                            Row(
                              children: [
                                Text(
                                  '$stt. ',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    student.hoTen,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  student.mssv,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                if (student.isAtRisk) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 12,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Cảnh báo',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Grades Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_selectedGradeType == 'all') ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildGradeItem(
                                'TX',
                                student.diemThuongXuyen,
                                student,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGradeItem(
                                'GK',
                                student.diemGiuaKy,
                                student,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGradeItem(
                                'CK',
                                student.diemCuoiKy,
                                student,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGradeItem(
                                'TK',
                                student.diemTongKet,
                                student,
                                isDark,
                                isTotal: true,
                              ),
                            ),
                          ],
                        ),
                      ] else if (_selectedGradeType == 'TX')
                        _buildGradeItem(
                          'TX',
                          student.diemThuongXuyen,
                          student,
                          isDark,
                        )
                      else if (_selectedGradeType == 'GK')
                        _buildGradeItem(
                          'GK',
                          student.diemGiuaKy,
                          student,
                          isDark,
                        )
                      else if (_selectedGradeType == 'CK')
                        _buildGradeItem(
                          'CK',
                          student.diemCuoiKy,
                          student,
                          isDark,
                        )
                      else if (_selectedGradeType == 'TK')
                        _buildGradeItem(
                          'TK',
                          student.diemTongKet,
                          student,
                          isDark,
                          isTotal: true,
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

  Widget _buildGradeItem(
    String label,
    double? grade,
    ClassStudent student,
    bool isDark, {
    bool isTotal = false,
  }) {
    final gradeColor = _getGradeColor(grade);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTotal
              ? AppTheme.bluePrimary.withOpacity(0.5)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(0.3),
          width: isTotal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isTotal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TỔNG KẾT',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark
                        ? const Color(0xFF1E3A8A).withOpacity(0.2)
                        : const Color(0xFFEBF4FF)),
                    (isDark
                        ? const Color(0xFF3B82F6).withOpacity(0.15)
                        : const Color(0xFFDEEDFF)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.bluePrimary.withOpacity(isDark ? 0.4 : 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.bluePrimary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                initialValue: grade?.toStringAsFixed(1) ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTheme.bodyLarge.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: false,
                  hintText: '0.0',
                  hintStyle: TextStyle(
                    color: (isDark
                        ? Colors.grey.shade600
                        : Colors.grey.shade400),
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: AppTheme.bluePrimary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixText: '/10',
                  suffixStyle: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onChanged: (value) {
                  final newGrade = double.tryParse(value);
                  if (newGrade != null && newGrade >= 0 && newGrade <= 10) {
                    _gradeChanges[student.mssv] ??= {};
                    _gradeChanges[student.mssv]![label] = newGrade;
                  }
                },
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  grade?.toStringAsFixed(1) ?? '-',
                  style: TextStyle(
                    fontSize: isTotal ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '/10',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGradeCell(
    ClassStudent student,
    String gradeType,
    double? currentGrade,
    bool isDark,
  ) {
    // This method is no longer used with the new card-based layout
    return const SizedBox.shrink();
  }

  Color _getGradeColor(double? grade) {
    if (grade == null) return Colors.grey;
    if (grade >= 8.5) return Colors.green;
    if (grade >= 7.0) return Colors.blue;
    if (grade >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSaveButton(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: _saveGradeChanges,
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.bluePrimary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Lưu thay đổi (${_gradeChanges.length})',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGradeChanges() async {
    if (_selectedClass == null || _gradeChanges.isEmpty) return;

    try {
      final provider = context.read<LecturerProvider>();
      
      // Save each grade change
      for (final entry in _gradeChanges.entries) {
        final mssv = entry.key;
        final grades = entry.value;
        
        await provider.updateGrade(
          mssv: mssv,
          maLop: _selectedClass!.maMon,
          diemQuaTrinh: grades['diemThuongXuyen'],
          diemGiuaKy: grades['diemGiuaKy'],
          diemCuoiKy: grades['diemCuoiKy'],
        );
      }

      if (!mounted) return;

      // Clear changes and reload
      setState(() {
        _gradeChanges.clear();
        _isEditing = false;
      });

      // Reload students to get updated data
      await _loadStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đã lưu ${_gradeChanges.length} thay đổi thành công!',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu điểm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import điểm từ Excel'),
        content: const Text('Chức năng đang phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export điểm ra Excel'),
        content: const Text('Chức năng đang phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    final avgTX =
        _students.map((s) => s.diemThuongXuyen ?? 0).reduce((a, b) => a + b) /
        _students.length;
    final avgGK =
        _students.map((s) => s.diemGiuaKy ?? 0).reduce((a, b) => a + b) /
        _students.length;
    final avgCK =
        _students.map((s) => s.diemCuoiKy ?? 0).reduce((a, b) => a + b) /
        _students.length;
    final avgTK =
        _students.map((s) => s.diemTongKet ?? 0).reduce((a, b) => a + b) /
        _students.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê điểm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm TB thường xuyên: ${avgTX.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Điểm TB giữa kỳ: ${avgGK.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Điểm TB cuối kỳ: ${avgCK.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Điểm TB tổng kết: ${avgTK.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
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
