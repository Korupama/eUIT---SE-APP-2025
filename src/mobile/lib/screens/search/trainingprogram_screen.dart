import 'package:flutter/material.dart';

class TrainingProgramScreen extends StatefulWidget {
  const TrainingProgramScreen({super.key});

  @override
  State<TrainingProgramScreen> createState() => _TrainingProgramScreenState();
}

class _TrainingProgramScreenState extends State<TrainingProgramScreen> {
  String selectedProgram = 'Công nghệ thông tin';
  int? expandedCategoryIndex;

  final List<String> programs = [
    'Công nghệ thông tin',
    'Kỹ thuật phần mềm',
    'Khoa học máy tính',
    'Hệ thống thông tin',
    'An toàn thông tin',
  ];

  final Map<String, Map<String, dynamic>> programData = {
    'Công nghệ thông tin': {
      'code': 'CNTT',
      'totalCredits': 150,
      'duration': '4 năm',
      'degree': 'Kỹ sư',
      'categories': [
        {
          'name': 'Kiến thức giáo dục đại cương',
          'credits': 45,
          'color': Color(0xFF3B82F6),
          'subjects': [
            'Triết học Mác - Lênin',
            'Kinh tế chính trị Mác - Lênin',
            'Chủ nghĩa xã hội khoa học',
            'Lịch sử Đảng Cộng sản Việt Nam',
            'Tư tưởng Hồ Chí Minh',
            'Tiếng Anh 1, 2, 3',
            'Giáo dục thể chất',
            'Toán cao cấp A1, A2, A3',
            'Vật lý đại cương',
          ],
        },
        {
          'name': 'Kiến thức giáo dục chuyên nghiệp',
          'credits': 90,
          'color': Color(0xFF10B981),
          'subjects': [
            'Cấu trúc dữ liệu và giải thuật',
            'Lập trình hướng đối tượng',
            'Cơ sở dữ liệu',
            'Mạng máy tính',
            'Hệ điều hành',
            'Công nghệ Web',
            'Phát triển ứng dụng di động',
            'Trí tuệ nhân tạo',
            'Học máy',
            'An ninh mạng',
            'Kiến trúc máy tính',
            'Phân tích thiết kế hệ thống',
          ],
        },
        {
          'name': 'Thực tập và Đồ án tốt nghiệp',
          'credits': 15,
          'color': Color(0xFFF59E0B),
          'subjects': [
            'Thực tập chuyên môn',
            'Thực tập tốt nghiệp',
            'Đồ án tốt nghiệp',
          ],
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chương trình đào tạo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program Selector
              _buildProgramSelector(),

              SizedBox(height: 20),

              // Program Overview
              _buildProgramOverview(),

              SizedBox(height: 20),

              // Git-style Credit Distribution
              _buildGitStyleDistribution(),

              SizedBox(height: 20),

              // Categories
              _buildCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: Color(0xFF06B6D4),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Chọn ngành đào tạo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedProgram,
                isExpanded: true,
                dropdownColor: Color(0xFF1E293B),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                items: programs.map((String program) {
                  return DropdownMenuItem<String>(
                    value: program,
                    child: Text(program),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedProgram = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramOverview() {
    final data = programData[selectedProgram];
    if (data == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chung',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Mã ngành',
                  data['code'],
                  Icons.tag,
                  Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  'Tổng tín chỉ',
                  '${data['totalCredits']}',
                  Icons.credit_card,
                  Color(0xFF10B981),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Thời gian',
                  data['duration'],
                  Icons.access_time,
                  Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  'Bằng cấp',
                  data['degree'],
                  Icons.workspace_premium,
                  Color(0xFFEC4899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitStyleDistribution() {
    final data = programData[selectedProgram];
    if (data == null) return SizedBox.shrink();

    final categories = data['categories'] as List;
    final totalCredits = data['totalCredits'] as int;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ tín chỉ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // Git-style progress bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(
                children: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final credits = category['credits'] as int;
                  final percentage = (credits / totalCredits);
                  final isFirst = index == 0;
                  final isLast = index == categories.length - 1;

                  return Flexible(
                    flex: (percentage * 1000).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: category['color'],
                        borderRadius: BorderRadius.only(
                          topLeft: isFirst ? Radius.circular(5) : Radius.zero,
                          bottomLeft: isFirst ? Radius.circular(5) : Radius.zero,
                          topRight: isLast ? Radius.circular(5) : Radius.zero,
                          bottomRight: isLast ? Radius.circular(5) : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Legend items
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: categories.map<Widget>((category) {
              final credits = category['credits'] as int;
              final percentage = (credits / totalCredits * 100);

              return InkWell(
                onTap: () {
                  // Optional: Add interaction
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: category['color'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category['color'],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: category['color'].withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category['name'].toString().split(' ').take(2).join(' '),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: category['color'],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 16),

          // Detailed breakdown
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              children: categories.map<Widget>((category) {
                final credits = category['credits'] as int;
                final percentage = (credits / totalCredits * 100);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: category['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category['name'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '$credits TC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final data = programData[selectedProgram];
    if (data == null) return SizedBox.shrink();

    final categories = data['categories'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết môn học',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isExpanded = expandedCategoryIndex == index;

          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildCategoryCard(category, index, isExpanded),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index, bool isExpanded) {
    final subjects = category['subjects'] as List;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? category['color'].withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandedCategoryIndex = isExpanded ? null : index;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${category['credits']} TC',
                    style: TextStyle(
                      color: category['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: subjects.asMap().entries.map((entry) {
                      final subjectIndex = entry.key;
                      final subject = entry.value;
                      final isLast = subjectIndex == subjects.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: category['color'].withOpacity(0.6),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subject,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}