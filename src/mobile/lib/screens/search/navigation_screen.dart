import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/screens/search/plan_screen.dart';
import 'package:mobile/screens/search/trainingprogram_screen.dart';
import 'package:mobile/screens/search/trainingregulations_screen.dart';
import '../../utils/app_localizations.dart';
import '../../theme/app_theme.dart';
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

  // Store keys (not raw strings) so we can localize dynamically
  final List<Map<String, dynamic>> _menuItems = [
    {
      'titleKey': 'menu_academic_results_title',
      'subtitleKey': 'menu_academic_results_subtitle',
      'icon': Icons.school_outlined,
      'color': Color(0xFF3B82F6),
      'route': '/academic-results',
    },
    {
      'titleKey': 'menu_training_score_title',
      'subtitleKey': 'menu_training_score_subtitle',
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFF8B5CF6),
      'route': '/training-score',
    },
    {
      'titleKey': 'menu_training_results_title',
      'subtitleKey': 'menu_training_results_subtitle',
      'icon': Icons.assessment_outlined,
      'color': Color(0xFF10B981),
      'route': '/training-results',
    },
    {
      'titleKey': 'menu_tuition_info_title',
      'subtitleKey': 'menu_tuition_info_subtitle',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFF59E0B),
      'route': '/tuition-info',
    },
    {
      'titleKey': 'menu_regulations_title',
      'subtitleKey': 'menu_regulations_subtitle',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFFEC4899),
      'route': '/regulations',
    },
    {
      'titleKey': 'menu_training_program_title',
      'subtitleKey': 'menu_training_program_subtitle',
      'icon': Icons.library_books_outlined,
      'color': Color(0xFF06B6D4),
      'route': '/training-program',
    },
    {
      'titleKey': 'menu_annual_plan_title',
      'subtitleKey': 'menu_annual_plan_subtitle',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFFEF4444),
      'route': '/annual-plan',
    },
  ];

  // Filter using localized strings so the search works for current locale
  List<Map<String, dynamic>> get _filteredItems {
    final loc = AppLocalizations.of(context);
    if (_searchQuery.isEmpty) {
      return _menuItems;
    }
    return _menuItems.where((item) {
      final title = loc.t(item['titleKey']).toLowerCase();
      final subtitle = loc.t(item['subtitleKey']).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToScreen(String route, String titleKey, Color color) {
    Widget screen;
    final loc = AppLocalizations.of(context);

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
            content: Text('${loc.t(titleKey)} — ${loc.t('coming_soon')}'),
            backgroundColor: color,
            duration: Duration(seconds: 1),
          ),
        );
        return;
    }

    // Navigate to the screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Ensure we leave space above the bottom navigation bar used in MainScreen
    // MainScreen uses baseHeight = 75.0 + MediaQuery.padding.bottom
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double navBarBaseHeight = AppTheme.bottomNavBaseHeight;
    final double navBarHeight = navBarBaseHeight + bottomInset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _filteredItems.isEmpty
                  // For empty state add bottom padding so content is visually above nav bar
                  ? Padding(
                      padding: EdgeInsets.only(bottom: navBarHeight),
                      child: _buildEmptyState(),
                    )
                  // For the grid, _buildMenuGrid will include bottom padding equal to navBarHeight
                  : _buildMenuGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final loc = AppLocalizations.of(context);

    // Make header taller to include the search bar beneath the title/subtitle
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AppBar-like title area
                SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.t('search_title'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.t('search_subtitle'),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar row
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1720)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withAlpha(24)
                            : Colors.black.withAlpha(6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.t('search_hint'),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white70 : Colors.black38,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark ? Colors.white70 : Colors.black45,
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
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    // Ensure GridView has extra bottom padding equal to the navigation bar height
    // (base 75.0 + device bottom inset) so items aren't obscured by the bottom nav.
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double navBarBaseHeight = AppTheme.bottomNavBaseHeight;
    final double navBarHeight = navBarBaseHeight + bottomInset;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + navBarHeight),
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
    final loc = AppLocalizations.of(context);
    // Make card background semi-transparent (~0.8 alpha) to match app-wide translucent cards
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color rawTileColor = Theme.of(context).cardColor;
    // For dark mode use the same card color as in services_screen.dart: Color.fromRGBO(30,41,59,0.62)
    final tileBg = isDark
        ? Color.fromRGBO(30, 41, 59, 0.62)
        : rawTileColor.withAlpha((0.8 * 255).round());
    final title = loc.t(item['titleKey']);
    final subtitle = loc.t(item['subtitleKey']);
    // For dark mode, use a semi-transparent white background for the inner icon box
    final Color innerIconBg = isDark
        ? Color.fromRGBO(255, 255, 255, 0.1)
        : tileBg;

    return GestureDetector(
      onTap: () {
        // Navigate to specific screen based on route
        _navigateToScreen(item['route'], item['titleKey'], item['color']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(
              context,
            ).dividerColor.withAlpha((0.08 * 255).round()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (item['color'] as Color).withAlpha((0.06 * 255).round()),
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
                        (item['color'] as Color).withAlpha(
                          (0.12 * 255).round(),
                        ),
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
                    // Inner mini-card for the icon; make it slightly translucent relative to tile
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // In dark mode use semi-transparent white to improve icon contrast; otherwise reuse tileBg
                        color: innerIconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 28),
                    ),

                    Spacer(),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color
                            ?.withAlpha((0.7 * 255).round()),
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
                    // arrow badge uses same translucent background as tile
                    color: tileBg,
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
    final loc = AppLocalizations.of(context);
    final iconColor =
        Theme.of(context).iconTheme.color?.withAlpha((0.2 * 255).round()) ??
        Colors.grey.withAlpha((0.2 * 255).round());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: iconColor),
          SizedBox(height: 16),
          Text(
            loc.t('no_results'),
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withAlpha((0.6 * 255).round()),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            loc.t('try_different_query'),
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha((0.5 * 255).round()),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
