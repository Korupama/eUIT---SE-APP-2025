import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/teaching_class.dart';
import '../../models/class_student.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerClassDetailScreen - Chi tiết lớp học
class LecturerClassDetailScreen extends StatefulWidget {
  final TeachingClass classInfo;

  const LecturerClassDetailScreen({
    super.key,
    required this.classInfo,
  });

  @override
  State<LecturerClassDetailScreen> createState() =>
      _LecturerClassDetailScreenState();
}

class _LecturerClassDetailScreenState extends State<LecturerClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ClassStudent> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    
    try {
      // Call API to get students in this class
      final provider = context.read<LecturerProvider>();
      final studentsData = await provider.fetchExamStudents(
        widget.classInfo.maMon,
      );

      if (!mounted) return;

      _students = studentsData.map((data) {
        return ClassStudent(
          mssv: data['mssv']?.toString() ?? '',
          hoTen: data['hoTen'] as String? ?? '',
          ngaySinh: data['ngaySinh'] != null
              ? DateTime.tryParse(data['ngaySinh'] as String)
              : null,
          gioiTinh: data['gioiTinh'] as String?,
          email: data['email'] as String?,
          soDienThoai: data['soDienThoai'] as String?,
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
      
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFF020617),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0f172a),
                          const Color(0xFF1e293b),
                        ]
                      : [
                          const Color(0xFF5B9BF3),
                          const Color(0xFF9B7FE8),
                        ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark),
                _buildClassInfoHeader(isDark),
                _buildTabBar(isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentList(isDark),
                      _buildGradesList(isDark),
                      _buildStatistics(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: (isDark ? Colors.white : Colors.white).withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.classInfo.tenMon,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.classInfo.maMon} - Nhóm ${widget.classInfo.nhom}',
                  style: TextStyle(
                    fontSize: 14,
                    color: (isDark ? Colors.white : Colors.white).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show more options
            },
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                _buildInfoChip(Icons.people_outline, '${widget.classInfo.siSo} SV', isDark),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.schedule, widget.classInfo.scheduleText, isDark),
                const SizedBox(width: 12),
                if (widget.classInfo.phong != null)
                  _buildInfoChip(Icons.room_outlined, widget.classInfo.phong!, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bluePrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.bluePrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.bluePrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Danh sách'),
                Tab(text: 'Điểm'),
                Tab(text: 'Thống kê'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(bool isDark) {
    if (_isLoading) {
      return _buildShimmerLoading(isDark);
    }

    List<ClassStudent> filteredStudents = _students;
    if (_searchQuery.isNotEmpty) {
      filteredStudents = _students.where((s) {
        return s.hoTen.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.mssv.contains(_searchQuery);
      }).toList();
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: TextStyle(
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sinh viên...',
                    hintStyle: TextStyle(
                      color: (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary).withOpacity(0.6),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Student list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              return _buildStudentCard(filteredStudents[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(ClassStudent student, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: student.isAtRisk
                    ? Colors.orange.withOpacity(0.5)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Show student detail
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.bluePrimary.withOpacity(0.2),
                        child: Text(
                          student.initials,
                          style: const TextStyle(
                            color: AppTheme.bluePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    student.hoTen,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (student.isAtRisk)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      'Cảnh báo',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
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
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  student.mssv,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.class_outlined,
                                  size: 14,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  student.lopSinhHoat ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (student.soTietVang != null && student.soTietVang! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 14,
                                      color: student.soTietVang! >= 3 ? Colors.red : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vắng ${student.soTietVang} tiết',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: student.soTietVang! >= 3 ? Colors.red : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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

  Widget _buildGradesList(bool isDark) {
    if (_isLoading) {
      return _buildShimmerLoading(isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildGradeCard(student, isDark);
      },
    );
  }

  Widget _buildGradeCard(ClassStudent student, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.bluePrimary.withOpacity(0.2),
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          color: AppTheme.bluePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.hoTen,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkText : AppTheme.lightText,
                            ),
                          ),
                          Text(
                            student.mssv,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGradeItem('TX', student.diemThuongXuyen, isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGradeItem('GK', student.diemGiuaKy, isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGradeItem('CK', student.diemCuoiKy, isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGradeItem(
                        'TK',
                        student.diemTongKet,
                        isDark,
                        isTotal: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeItem(String label, double? grade, bool isDark, {bool isTotal = false}) {
    final hasGrade = grade != null;
    final color = hasGrade
        ? (grade >= 8.5
            ? AppTheme.success
            : grade >= 7.0
                ? AppTheme.bluePrimary
                : grade >= 5.0
                    ? Colors.orange
                    : AppTheme.error)
        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isTotal
            ? color.withOpacity(0.15)
            : (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: isTotal ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasGrade ? grade.toStringAsFixed(1) : '-',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isDark) {
    if (_isLoading) {
      return _buildShimmerLoading(isDark);
    }

    final totalStudents = _students.length;
    final activeStudents = _students.where((s) => s.trangThai == 'Đang học').length;
    final atRiskStudents = _students.where((s) => s.isAtRisk).length;
    final avgGrade = _students
        .where((s) => s.diemTongKet != null)
        .map((s) => s.diemTongKet!)
        .fold<double>(0, (sum, grade) => sum + grade) / 
        _students.where((s) => s.diemTongKet != null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            'Tổng số sinh viên',
            totalStudents.toString(),
            Icons.people,
            AppTheme.bluePrimary,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Đang học',
            activeStudents.toString(),
            Icons.school,
            AppTheme.success,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Cần chú ý',
            atRiskStudents.toString(),
            Icons.warning_amber,
            Colors.orange,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Điểm TB lớp',
            avgGrade.isNaN ? 'N/A' : avgGrade.toStringAsFixed(2),
            Icons.bar_chart,
            AppTheme.bluePrimary,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
