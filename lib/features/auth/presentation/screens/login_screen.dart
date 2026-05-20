import 'package:flutter/material.dart';
import 'security_lock_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

// LoginScreen now just redirects to SecurityLockScreen
// Kept for backward compatibility
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SecurityLockScreen(nextScreen: const DashboardScreen());
  }
}
