import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/haptic_service.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _handleNavigation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (settings.isBiometricsEnabled) {
      setState(() => _isAuthenticating = true);
      final authenticated = await BiometricService.authenticate(
        reason: 'Authenticate to unlock ExpenseFlow',
      );
      if (!authenticated && mounted) {
        _promptRetryAuth();
        return;
      }
    }

    _navigateToHome();
  }

  void _promptRetryAuth() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('Biometric verification failed. Please try again.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleNavigation();
            },
            child: const Text('Retry Authentication'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    HapticService.lightImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const MainNavigationScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProv.primaryColor.withOpacity(0.85),
              theme.scaffoldBackgroundColor,
              themeProv.accentColor.withOpacity(0.15),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // High-Performance Animated Vector Logo
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeProv.accentColor.withOpacity(0.2),
                          border: Border.all(
                            color: themeProv.accentColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeProv.accentColor.withOpacity(0.35),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 54,
                          color: themeProv.accentColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ExpenseFlow',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Offline-First Financial Intelligence',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (_isAuthenticating) ...[
                        const SizedBox(height: 32),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
