import 'package:flutter/material.dart';
import 'patient_dashboard_page.dart';
import 'ai_chat_page.dart';
import 'pharmacy_map_page.dart';
import 'patient_profile_page.dart';
import '../../../../core/theme/app_colors.dart';

class PatientMainPage extends StatefulWidget {
  const PatientMainPage({super.key});

  @override
  State<PatientMainPage> createState() => _PatientMainPageState();
}

class _PatientMainPageState extends State<PatientMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PatientDashboardPage(),
    const AiChatPage(),
    const PharmacyMapPage(),
    const PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: const IconThemeData(color: AppColors.primaryDark),
        backgroundColor: AppColors.surface,
        items: [
          _buildNavItem(Icons.home_outlined, Icons.home, 'Beranda', 0),
          _buildNavItem(Icons.smart_toy_outlined, Icons.smart_toy, 'AI Asisten', 1),
          _buildNavItem(Icons.map_outlined, Icons.map, 'Peta', 2),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profil', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(isSelected ? selectedIcon : unselectedIcon),
      ),
      label: label,
    );
  }
}
