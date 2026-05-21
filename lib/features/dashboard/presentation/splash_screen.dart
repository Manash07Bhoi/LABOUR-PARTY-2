import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture,
              size: 80,
              color: AppTheme.primaryColor,
            ).animate().fade().scale(duration: 500.ms),
            const SizedBox(height: 24),
            const Text(
              'Labour Party',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppTheme.accentColor,
            ).animate().fade(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
