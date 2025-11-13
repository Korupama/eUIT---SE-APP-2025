import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../utils/app_localizations.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // home

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _PlaceholderPage(label: 'services'),
      const _PlaceholderPage(label: 'search'),
      const HomeScreen(),
      const _PlaceholderPage(label: 'schedule'),
      const _PlaceholderPage(label: 'settings'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    // TODO: Implement skeleton loading here while provider is fetching data from API.

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(loc),
    );
  }

  Widget _buildBottomNav(AppLocalizations loc) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColorsTheme.cardBackground,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.shade500,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.apps), label: loc.t('services')),
        BottomNavigationBarItem(icon: const Icon(Icons.search), label: loc.t('search')),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColorsTheme.primaryAccent, shape: BoxShape.circle),
            child: const Icon(Icons.home, color: Colors.black, size: 28),
          ),
          label: loc.t('home'),
        ),
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: loc.t('schedule')),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: loc.t('settings')),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      color: AppColorsTheme.background,
      alignment: Alignment.center,
      child: Text(loc.t(label), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

