import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/core/routes/app_routes.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'package:world_bank_loan/landing_page.dart';
// Import needed only if we use AppProviders
import 'package:world_bank_loan/providers/app_provider.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import 'package:world_bank_loan/screens/splash_screen/splash_screen.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// For web platform optimizations
final bool isReleaseMode = const bool.fromEnvironment('dart.vm.product');

// Global key for checking if app is initialized
final ValueNotifier<bool> appInitialized = ValueNotifier<bool>(false);

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Optimize for performance
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for better visual appearance during load
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Web-specific initialization to handle HTML splash screen
  if (kIsWeb) {
    // Use a post-frame callback to detect when the app has rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hide the HTML splash screen when Flutter app has rendered its first frame
      _hideWebSplashScreen();

      // Set app as initialized
      appInitialized.value = true;
    });
  }

  // Run the app with ProviderScope but without the extra wrapper
  runApp(
    ProviderScope(
      child: AppProviders(
        child: MyApp(),
      ),
    ),
  );
}

// Function to hide the HTML splash screen
void _hideWebSplashScreen() {
  // Try to get the splash element from the DOM
  final splashElement = html.document.getElementById('splash-screen');

  if (splashElement != null) {
    // Add a fade-out class to the splash element
    splashElement.classes.add('splash-screen-fade-out');

    // Remove the element after animation completes
    Future.delayed(Duration(milliseconds: 500), () {
      splashElement.remove();
    });
  }

  // Set body style to ensure the Flutter app is visible
  html.document.body?.style.background = 'transparent';
  html.document.body?.style.overflow = 'auto';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Authentication status
  bool? _isAuthenticated;
  bool _isLoading = true;
  String? _savedRoute;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Initialize app resources and check authentication
  Future<void> _initializeApp() async {
    // Check authentication state first
    final token = await UserSession.getToken();
    _isAuthenticated = token != null;

    // Check for saved route
    final prefs = await SharedPreferences.getInstance();
    _savedRoute = prefs.getString('last_route');

    // Pre-load any essential resources here
    await _preloadResources();

    // Mark initialization as complete
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Set global initializer to true for state restoration
      appInitialized.value = true;
    }
  }

  // Preload any essential app resources
  Future<void> _preloadResources() async {
    // Add any critical resource loading here
    // For example: preload images, initial API data, etc.
    await Future.delayed(Duration(
        milliseconds: 300)); // Ensure minimum time for resources to load
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on loading, authentication, and saved route
    String initialRoute;
    if (_isLoading) {
      initialRoute = AppRoutes.splash;
    } else if (_isAuthenticated == true) {
      // If authenticated and has saved route, use it
      if (_savedRoute != null &&
          _savedRoute!.isNotEmpty &&
          _savedRoute != AppRoutes.landing &&
          _savedRoute != '/') {
        initialRoute = _savedRoute!;
      } else {
        initialRoute = AppRoutes.main;
      }
    } else {
      initialRoute = AppRoutes.landing;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'World Bank Loan',
      // Reduce theme initialization overhead
      theme: _buildTheme(),
      // Use initialRoute instead of home
      initialRoute: initialRoute,
      // Use the AppRoutes for route generation
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }

  // Extracted theme building for better readability
  ThemeData _buildTheme() {
    return AppTheme.lightTheme().copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.authorityBlue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
