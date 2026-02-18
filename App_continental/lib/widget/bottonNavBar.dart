import 'package:continental/feature/actionable/actionableScreen.dart';
import 'package:continental/feature/dashboard/dashboardScreen.dart';
import 'package:continental/feature/menu/menuScreen.dart';
import 'package:continental/feature/portfolio/potfolioScreen.dart';
import 'package:continental/provider/bottonNavBarPro.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:continental/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNav extends ConsumerStatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Dashboardscreen(),
    PortfolioScreen(),
    ActionableScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final languageCode = ref.watch(languageProvider);
    String t(String key) => LanguageService.translate(key, languageCode);
    
    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: (int newIndex) {
         ref.read(bottomNavIndexProvider.notifier).state = newIndex;
        },
         type: BottomNavigationBarType.fixed,
  //  showSelectedLabels: false,
  // showUnselectedLabels: false,
  selectedItemColor: Colors.white,        // ✅ Selected icon color
  unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard, ),
            label: t('DashBoard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined, ),
            label: t('Potfolio'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_work_outlined,),
            label: t('Properties'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu, ),
            label: t('Menu'),
          ),
        ],
      ),
    );
  }
}