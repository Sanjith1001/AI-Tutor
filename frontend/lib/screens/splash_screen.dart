import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_wrapper.dart';

class ByteBrainSplashScreen extends StatefulWidget {
  const ByteBrainSplashScreen({super.key});

  @override
  State<ByteBrainSplashScreen> createState() => _ByteBrainSplashScreenState();
}

class _ByteBrainSplashScreenState extends State<ByteBrainSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Logo animations with spring curve
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Tagline animations
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    // Screen fade out animation
    _screenFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start logo animation immediately
    _logoController.forward();

    // Wait for logo animation to complete, then start tagline
    await Future.delayed(const Duration(milliseconds: 400));
    _taglineController.forward();

    // Wait for total splash duration, then fade out and navigate
    await Future.delayed(const Duration(milliseconds: 1300));
    _fadeOutController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      // Navigate to login
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double fontTitle = size.width * 0.09;
    final double fontTagline = size.width * 0.045;
    final double spacing = size.height * 0.03;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _screenFadeOut,
        builder: (context, child) {
          return Opacity(
            opacity: _screenFadeOut.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.lightGreen],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoScale, _logoOpacity]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Text(
                              'ByteBrain',
                              style: TextStyle(
                                fontSize: fontTitle,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: spacing),

                    // Animated Tagline
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([_taglineOpacity, _taglineSlide]),
                      builder: (context, child) {
                        return SlideTransition(
                          position: _taglineSlide,
                          child: Opacity(
                            opacity: _taglineOpacity.value,
                            child: Text(
                              'Learn. Practice. Excel.',
                              style: TextStyle(
                                fontSize: fontTagline,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
