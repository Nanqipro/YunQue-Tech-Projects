import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile/profile_screen.dart';
import 'vocabulary/vocabulary_screen.dart';
import 'listening/listening_screen.dart';
import 'reading/reading_screen.dart';
import 'writing/writing_screen.dart';
import 'speaking/speaking_screen.dart';
import '../constants/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ProfileScreen(),
    const VocabularyScreen(),
    const ListeningScreen(),
    const SpeakingScreen(),
    const ReadingScreen(),
    const WritingScreen(),
  ];
  
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.user),
      label: '个人',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.book),
      label: '词汇',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.headphones),
      label: '听力',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.microphone),
      label: '口语',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.bookOpen),
      label: '阅读',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.pen),
      label: '写作',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textHintColor,
        backgroundColor: AppTheme.surfaceColor,
        elevation: 8,
        items: _bottomNavItems,
      ),
    );
  }
}