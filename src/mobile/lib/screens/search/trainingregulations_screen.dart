import 'package:flutter/material.dart';

class TrainingRegulationsScreen extends StatefulWidget {
  const TrainingRegulationsScreen({super.key});

  @override
  State<TrainingRegulationsScreen> createState() => _TrainingRegulationsScreenState();
}

class _TrainingRegulationsScreenState extends State<TrainingRegulationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> regulations = [
    {
      'title': 'Quy chế học vụ',
      'description': 'Quy định về việc đăng ký môn học, thi cử, và xét tốt nghiệp.',
      'icon': Icons.school_outlined,
      'color': Color(0xFF3B82F6),
    },
    {
      'title': 'Quy định về học phí',
      'description': 'Các quy định liên quan đến việc thu và quản lý học phí.',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Nội quy sinh viên',
      'description': 'Quy định về quyền và nghĩa vụ của sinh viên trong trường.',
      'icon': Icons.gavel_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'Quy chế thi và kiểm tra',
      'description': 'Quy định về việc tổ chức thi, kiểm tra và đánh giá.',
      'icon': Icons.assignment_outlined,
      'color': Color(0xFF8B5CF6),
    },
    {
      'title': 'Quy định về rèn luyện',
      'description': 'Hướng dẫn về hoạt động rèn luyện và đánh giá điểm rèn luyện.',
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Quy chế thực tập',
      'description': 'Quy định về thực tập tốt nghiệp và thực tập chuyên môn.',
      'icon': Icons.work_outline,
      'color': Color(0xFF06B6D4),
    },
  ];

  List<Map<String, dynamic>> get _filteredRegulations {
    if (_searchQuery.isEmpty) {
      return regulations;
    }
    return regulations.where((item) {
      final title = item['title'].toString().toLowerCase();
      final description = item['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Quy chế & Đào tạo',
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
              // Search Section
              _buildSearchSection(),

              SizedBox(height: 24),

              // Regulations List
              _buildRegulationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
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
            'Tìm kiếm văn bản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
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
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa để tìm kiếm (ví dụ: học vụ, học phí...)',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulationsList() {
    if (_filteredRegulations.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredRegulations.map((regulation) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _buildRegulationCard(regulation),
        );
      }).toList(),
    );
  }

  Widget _buildRegulationCard(Map<String, dynamic> regulation) {
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
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: regulation['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              regulation['icon'],
              color: regulation['color'],
              size: 24,
            ),
          ),

          SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  regulation['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  regulation['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12),

          // Download Button
          InkWell(
            onTap: () {
              _handleDownload(regulation['title']);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: regulation['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.download_outlined,
                color: regulation['color'],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDownload(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải về: $title'),
        backgroundColor: Color(0xFF3B82F6),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}