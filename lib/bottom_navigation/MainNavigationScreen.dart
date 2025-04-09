import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:world_bank_loan/screens/card_section/card_screen.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'package:world_bank_loan/screens/profile_section/profile_screen.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:world_bank_loan/services/notification_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final Color navigationBarColor = Colors.white;
  late PageController pageController;
  int selectedIndex = 0;
  late List<Widget> _pages;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);

    // Initialize FCM token and send it to the server
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Refresh and update the FCM token
      final notificationService = NotificationService();
      await notificationService.refreshAndUpdateToken();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _pages = [
        const HomeScreen(),
        const CardScreen(),
        const ContactScreen(),
        const ProfileScreen(),
      ];
      _isInit = true;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _onPageChanged(int index) async {
    if (!mounted) return;
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _navigationHandler(int index) async {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    try {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuad,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const CircularProgressIndicator();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: WaterDropNavBar(
                backgroundColor: navigationBarColor,
                onItemSelected: _navigationHandler,
                selectedIndex: selectedIndex,
                barItems: [
                  BarItem(
                    filledIcon: Icons.home_rounded,
                    outlinedIcon: Icons.home_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.credit_card_rounded,
                    outlinedIcon: Icons.credit_card_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.headset_mic_rounded,
                    outlinedIcon: Icons.headset_mic_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.person_rounded,
                    outlinedIcon: Icons.person_outline_rounded,
                  ),
                ],
                waterDropColor: _getSelectedColor(),
                bottomPadding:
                    MediaQuery.of(context).padding.bottom > 0 ? 0 : 10,
                iconSize: 28,
                inactiveIconColor: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSelectedColor() {
    switch (selectedIndex) {
      case 0:
        return const Color(0xFF3366FF); // Home - Blue
      case 1:
        return const Color(0xFF4E54C8); // Card - Purple
      case 2:
        return const Color(0xFF11998E); // Support - Teal
      case 3:
        return const Color(0xFF6B73FF); // Profile - Indigo
      default:
        return const Color(0xFF3366FF);
    }
  }
}
