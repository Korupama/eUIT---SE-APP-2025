import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/teaching_class.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerClassListScreen - Danh sách lớp giảng dạy
class LecturerClassListScreen extends StatefulWidget {
  final bool showBackButton;

  const LecturerClassListScreen({super.key, this.showBackButton = false});

  @override
  State<LecturerClassListScreen> createState() =>
      _LecturerClassListScreenState();
}

class _LecturerClassListScreenState extends State<LecturerClassListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;
  String _selectedSemester = 'all';
  String _selectedYear = '2024-2025';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Fetch teaching classes when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LecturerProvider>().fetchTeachingClasses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                // Header with search and filter
                _buildHeader(isDark),

                // Class list
                Expanded(
                  child: provider.isLoading
                      ? _buildShimmerLoading(isDark)
                      : _buildClassList(provider, isDark),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              if (widget.showBackButton)
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
                child: Icon(
                  Icons.class_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Danh sách lớp',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard)
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                        .withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm môn học, mã môn...',
                    hintStyle: TextStyle(
                      color:
                          (isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary)
                              .withOpacity(0.6),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Year and Semester filters
          Row(
            children: [
              // Year dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkCard : AppTheme.lightCard)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                      style: TextStyle(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        fontSize: 14,
                      ),
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      items:
                          [
                            '2024-2025',
                            '2023-2024',
                            '2022-2023',
                            '2021-2022',
                          ].map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text('Năm học $year'),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedYear = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Semester label
              Text(
                'Học kỳ:',
                style: TextStyle(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Semester filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('HK1', 'hk1', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('HK2', 'hk2', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('HK3', 'hk3', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedSemester == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSemester = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppTheme.darkCard : AppTheme.lightCard).withOpacity(
                  0.6,
                ),
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
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppTheme.darkText : AppTheme.lightText),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildClassList(LecturerProvider provider, bool isDark) {
    List<TeachingClass> classes = provider.teachingClasses;

    // Apply filters
    if (_selectedSemester != 'all') {
      classes = classes
          .where((c) => c.hocKy?.toLowerCase() == _selectedSemester)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      classes = classes.where((c) {
        return c.tenMon.toLowerCase().contains(_searchQuery) ||
            c.maMon.toLowerCase().contains(_searchQuery) ||
            c.nhom.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (classes.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchTeachingClasses();
      },
      color: AppTheme.bluePrimary,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 84),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return _buildClassCard(classes[index], isDark, index);
        },
      ),
    );
  }

  Widget _buildClassCard(TeachingClass classItem, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                0.8,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/lecturer_class_detail',
                    arguments: classItem,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Course code + Status badge
                      Row(
                        children: [
                          // Course code badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              classItem.maMon,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Status badge
                          if (classItem.trangThai != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  classItem.statusColor,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(
                                    classItem.statusColor,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                classItem.trangThai!,
                                style: TextStyle(
                                  color: _getStatusColor(classItem.statusColor),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Arrow icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Course name
                      Text(
                        classItem.tenMon,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkText
                              : AppTheme.lightText,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Info grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              Icons.group_outlined,
                              'Nhóm ${classItem.nhom}',
                              isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              Icons.people_outline,
                              '${classItem.siSo} SV',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              Icons.school_outlined,
                              '${classItem.soTinChi} TC',
                              isDark,
                            ),
                          ),
                          if (classItem.phong != null)
                            Expanded(
                              child: _buildInfoItem(
                                Icons.room_outlined,
                                classItem.phong!,
                                isDark,
                              ),
                            ),
                        ],
                      ),

                      // Schedule info
                      if (classItem.thu != null && classItem.tietBatDau != null)
                        Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.bluePrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.bluePrimary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: AppTheme.bluePrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      classItem.scheduleText,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkText
                                            : AppTheme.lightText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppTheme.darkTextSecondary
              : AppTheme.lightTextSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String statusType) {
    switch (statusType) {
      case 'success':
        return AppTheme.success;
      case 'warning':
        return Colors.orange;
      case 'neutral':
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80,
            color:
                (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy lớp học',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc tìm kiếm',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 84),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkCard : Colors.white)
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                        .withOpacity(0.3),
                  ),
                ),
                child: Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 70,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
