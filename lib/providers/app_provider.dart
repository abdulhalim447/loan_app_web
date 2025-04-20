import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_provider.dart';
import 'home_provider.dart';
import 'withdraw_provider.dart';
import 'personal_info_provider.dart';

/// This class provides all the providers needed in the app in one place
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use lazy parameter for providers to improve startup time
        ChangeNotifierProvider(create: (_) => CardProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => HomeProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => WithdrawProvider(), lazy: true),
        ChangeNotifierProvider(
            create: (_) => PersonalInfoProvider(), lazy: true),
        // Add more providers here as needed
      ],
      child: child,
    );
  }
}

/// This is a simplified version that doesn't use providers initially
/// to improve app startup time
class EssentialProviders extends StatelessWidget {
  final Widget child;

  const EssentialProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Simply return the child without wrapping it in providers
    // This avoids the MultiProvider with empty list which causes the error
    return child;
  }
}
