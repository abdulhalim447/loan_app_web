import 'package:flutter/material.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'package:world_bank_loan/screens/home_section/withdraw/withdraw_screen.dart';
import 'package:world_bank_loan/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:world_bank_loan/screens/notifications/notification_screen.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/landing_page.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import 'package:world_bank_loan/screens/splash_screen/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String landing = '/';
  static const String splash = '/splash';
  static const String main = '/main';
  static const String home = '/home';
  static const String personalInfo = '/personal_info';
  static const String loanApplication = '/loan_application';
  static const String withdraw = '/withdraw';
  static const String notifications = '/notifications';
  static const String contact = '/contact';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      personalInfo: (context) => PersonalInfoScreen(),
      loanApplication: (context) => LoanApplicationScreen(),
      withdraw: (context) => WithdrawScreen(),
      notifications: (context) => const NotificationScreen(),
      contact: (context) => ContactScreen(),
    };
  }

  // Generate routes for onGenerateRoute
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => LandingPage());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case main:
        return MaterialPageRoute(builder: (_) => MainNavigationScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case personalInfo:
        return MaterialPageRoute(builder: (_) => PersonalInfoScreen());
      case loanApplication:
        return MaterialPageRoute(builder: (_) => LoanApplicationScreen());
      case withdraw:
        return MaterialPageRoute(builder: (_) => WithdrawScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case contact:
        return MaterialPageRoute(builder: (_) => ContactScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
