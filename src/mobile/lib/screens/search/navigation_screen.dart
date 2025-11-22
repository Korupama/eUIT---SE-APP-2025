import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/screens/search/plan_screen.dart';
import 'package:mobile/screens/search/trainingprogram_screen.dart';
import 'package:mobile/screens/search/trainingregulations_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';
import 'studyresult_screen.dart';
import 'trainingpoint_screen.dart';
import 'progress_screen.dart';
import 'tuition_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Kết quả học tập',
      'subtitle': 'Xem điểm theo kỳ và GPA',
      'icon': Icons.school_outlined,
      'color': Color(0xFF3B82F6),
      'route': '/academic-results',
    },
    {
      'title': 'Điểm rèn luyện',
      'subtitle': 'Điểm rèn luyện theo kỳ',
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFF8B5CF6),
      'route': '/training-score',
    },
    {
      'title': 'Kết quả đào tạo',
      'subtitle': 'Theo dõi tiến độ đào tạo',
      'icon': Icons.assessment_outlined,
      'color': Color(0xFF10B981),
      'route': '/training-results',
    },
    {
      'title': 'Thông tin học phí',
      'subtitle': 'Kiểm tra học phí và hóa đơn',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFF59E0B),
      'route': '/tuition-info',
    },
    {
      'title': 'Quy chế đào tạo',
      'subtitle': 'Nội quy và quy định của trường',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFFEC4899),
      'route': '/regulations',
    },
    {
      'title': 'Chương trình đào tạo',
      'subtitle': 'Hệ chính quy và hệ từ xa',
      'icon': Icons.library_books_outlined,
      'color': Color(0xFF06B6D4),
      'route': '/training-program',
    },
    {
      'title': 'Kế hoạch năm học',
      'subtitle': 'Lịch trình năm học, sự kiện',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFFEF4444),
      'route': '/annual-plan',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _menuItems;
    }
    return _menuItems.where((item) {
      final title = item['title'].toString().toLowerCase();
      final subtitle = item['subtitle'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToScreen(String route, String title, Color color) {
    Widget? screen;

    switch (route) {
      case '/academic-results':
        screen = StudyResultScreen();
        break;
      case '/training-score':
        screen = TrainingPointScreen();
        break;
      case '/training-results':
        screen = ProgressScreen();
        break;
      case '/tuition-info':
        screen = TuitionScreen();
        break;
      case '/regulations':
        screen = TrainingRegulationsScreen();
        break;
      case '/training-program':
        screen = TrainingProgramScreen();
        break;
      case '/annual-plan':
        screen = PlanScreen();
        break;
      default:
      // Show snackbar for screens not yet implemented
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title đang được phát triển'),
            backgroundColor: color,
            duration: Duration(seconds: 1),
          ),
        );
        return;
    }

    // Navigate to the screen
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            _buildHeader(),

            // Content
            Expanded(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : _buildMenuGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Tra cứu thông tin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tìm kiếm thông tin sinh viên',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          SizedBox(height: 20),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
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
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.6),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.6),
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
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(_filteredItems[index]);
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        // Navigate to specific screen based on route
        _navigateToScreen(item['route'], item['title'], item['color']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item['color'].withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient Overlay
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        item['color'].withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'],
                        color: item['color'],
                        size: 28,
                      ),
                    ),

                    Spacer(),

                    // Title
                    Text(
                      item['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),

                    // Subtitle
                    Text(
                      item['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: item['color'],
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}