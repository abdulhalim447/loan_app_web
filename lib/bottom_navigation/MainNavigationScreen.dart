import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/screens/card_section/card_screen.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'package:world_bank_loan/screens/profile_section/profile_screen.dart';
import 'package:world_bank_loan/core/widgets/responsive_screen.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/home_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  final Color navigationBarColor = Colors.white;
  late PageController pageController;
  int selectedIndex = 0;
  late List<Widget> _pages;
  bool _isInit = false;
  static const String NAV_INDEX_KEY = 'navigation_index';

  // Add a key for exit dialog
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Keep track of when the app goes to background
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _loadSavedIndex();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App is in background
        _pausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        // App is in foreground again
        if (_pausedTime != null) {
          final difference = DateTime.now().difference(_pausedTime!);
          // If app was in background for more than 5 minutes, refresh data
          if (difference.inMinutes >= 5) {
            _refreshCurrentScreen();
          }
        }
        break;
      default:
        break;
    }
  }

  // Refresh the current screen's data
  void _refreshCurrentScreen() {
    switch (selectedIndex) {
      case 0:
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        homeProvider.fetchUserData();
        break;
      // Add other cases for other tabs if needed
    }
  }

  // Load saved navigation index
  Future<void> _loadSavedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(NAV_INDEX_KEY) ?? 0;

    setState(() {
      selectedIndex = savedIndex;
      pageController = PageController(initialPage: selectedIndex);
    });
  }

  // Save navigation index
  Future<void> _saveNavigationIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(NAV_INDEX_KEY, index);
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
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }

  Future<void> _onPageChanged(int index) async {
    if (!mounted) return;
    setState(() {
      selectedIndex = index;
    });
    await _saveNavigationIndex(index);
  }

  Future<void> _navigationHandler(int index) async {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    await _saveNavigationIndex(index);

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

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (selectedIndex != 0) {
      // If not on home screen, navigate to home screen
      _navigationHandler(0);
      return false;
    } else {
      // If on home screen, show exit dialog
      return await _showExitConfirmationDialog() ?? false;
    }
  }

  // Show dialog to confirm exit
  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('আপনি কি অ্যাপ থেকে বের হতে চান?'),
        content: const Text('আপনি কি নিশ্চিত যে আপনি অ্যাপ থেকে বের হতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('না'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const CircularProgressIndicator();

    final navigationContent = WillPopScope(
      onWillPop: _onWillPop,
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                  _buildNavItem(
                      1, Icons.credit_card_rounded, Icons.credit_card_outlined),
                  _buildNavItem(
                      2, Icons.headset_mic_rounded, Icons.headset_mic_outlined),
                  _buildNavItem(
                      3, Icons.person_rounded, Icons.person_outline_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: ResponsiveScreen(
        child: navigationContent,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData filledIcon, IconData outlinedIcon) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? _getSelectedColor() : Colors.grey.shade600;

    return InkWell(
      onTap: () => _navigationHandler(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: color,
              size: 28,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
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
