import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/teaching_class.dart';
import '../../models/class_student.dart';
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
      context.read<LecturerProvider>().fetchTeachingClasses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    if (_selectedClass == null) return;

    setState(() {
      _isLoading = true;
    });

    // Mock data - replace with API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _students = List.generate(45, (index) {
          final names = [
            'Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D', 'Hoàng Văn E',
            'Vũ Thị F', 'Đặng Văn G', 'Bùi Thị H', 'Đỗ Văn I', 'Ngô Thị K',
          ];
          return ClassStudent(
            mssv: '${21520000 + index}',
            hoTen: names[index % names.length] + ' ${index + 1}',
            ngaySinh: DateTime(2003, 1 + index % 12, 1 + index % 28),
            email: 'student${index + 1}@gm.uit.edu.vn',
            diemThuongXuyen: 7.0 + (index % 3) * 0.5,
            diemGiuaKy: 6.5 + (index % 4) * 0.75,
            diemCuoiKy: 7.5 + (index % 3) * 0.5,
            diemTongKet: 7.2 + (index % 3) * 0.4,
            soTietVang: index % 5,
            trangThai: index % 10 == 0 ? 'Cảnh báo' : 'Bình thường',
          );
        });
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
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
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
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
                color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
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
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Nhóm ${teachingClass.nhom}',
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${teachingClass.siSo} SV',
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            (isDark ? AppTheme.darkCard : Colors.grey.shade100).withOpacity(0.7),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.bluePrimary.withOpacity(0.1);
            }
            return (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.3);
          }),
          border: TableBorder.all(
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
          ),
          columns: [
            DataColumn(
              label: Text(
                'STT',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'MSSV',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Họ và tên',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (_selectedGradeType == 'all' || _selectedGradeType == 'TX')
              DataColumn(
                label: Text(
                  'TX',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            if (_selectedGradeType == 'all' || _selectedGradeType == 'GK')
              DataColumn(
                label: Text(
                  'GK',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            if (_selectedGradeType == 'all' || _selectedGradeType == 'CK')
              DataColumn(
                label: Text(
                  'CK',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            if (_selectedGradeType == 'all' || _selectedGradeType == 'TK')
              DataColumn(
                label: Text(
                  'TK',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
          ],
          rows: filteredStudents.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(
                  '${index + 1}',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                )),
                DataCell(Text(
                  student.mssv,
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                )),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      student.hoTen,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (_selectedGradeType == 'all' || _selectedGradeType == 'TX')
                  DataCell(_buildGradeCell(student, 'TX', student.diemThuongXuyen, isDark)),
                if (_selectedGradeType == 'all' || _selectedGradeType == 'GK')
                  DataCell(_buildGradeCell(student, 'GK', student.diemGiuaKy, isDark)),
                if (_selectedGradeType == 'all' || _selectedGradeType == 'CK')
                  DataCell(_buildGradeCell(student, 'CK', student.diemCuoiKy, isDark)),
                if (_selectedGradeType == 'all' || _selectedGradeType == 'TK')
                  DataCell(_buildGradeCell(student, 'TK', student.diemTongKet, isDark)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGradeCell(ClassStudent student, String gradeType, double? currentGrade, bool isDark) {
    if (!_isEditing) {
      return Text(
        currentGrade?.toStringAsFixed(1) ?? '-',
        style: AppTheme.bodySmall.copyWith(
          color: _getGradeColor(currentGrade),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SizedBox(
      width: 60,
      child: TextFormField(
        initialValue: currentGrade?.toStringAsFixed(1) ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTheme.bodySmall.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
            ),
          ),
        ),
        onChanged: (value) {
          final grade = double.tryParse(value);
          if (grade != null && grade >= 0 && grade <= 10) {
            _gradeChanges[student.mssv] ??= {};
            _gradeChanges[student.mssv]![gradeType] = grade;
          }
        },
      ),
    );
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
      backgroundColor: AppTheme.bluePrimary,
      icon: const Icon(Icons.save, color: Colors.white),
      label: Text(
        'Lưu thay đổi',
        style: AppTheme.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _saveGradeChanges() {
    // TODO: Save grade changes to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu ${_gradeChanges.length} thay đổi'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _isEditing = false;
      _gradeChanges.clear();
    });
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
    final avgTX = _students.map((s) => s.diemThuongXuyen ?? 0).reduce((a, b) => a + b) / _students.length;
    final avgGK = _students.map((s) => s.diemGiuaKy ?? 0).reduce((a, b) => a + b) / _students.length;
    final avgCK = _students.map((s) => s.diemCuoiKy ?? 0).reduce((a, b) => a + b) / _students.length;
    final avgTK = _students.map((s) => s.diemTongKet ?? 0).reduce((a, b) => a + b) / _students.length;

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
