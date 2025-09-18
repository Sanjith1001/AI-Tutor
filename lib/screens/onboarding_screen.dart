import 'login_screen.dart';
import 'package:flutter/material.dart';

class ByteBrainOnboardingScreen extends StatefulWidget {
  const ByteBrainOnboardingScreen({super.key});

  @override
  State<ByteBrainOnboardingScreen> createState() =>
      _ByteBrainOnboardingScreenState();
}

class _ByteBrainOnboardingScreenState extends State<ByteBrainOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      icon: Icons.school_outlined,
      title: 'Learn Smarter',
      description:
          'Access CBSE & ICSE content from 6th to 10th\nanytime, anywhere.',
      backgroundColor: const Color(0xFFE0F7FA),
    ),
    OnboardingData(
      icon: Icons.quiz_outlined,
      title: 'Interactive Quizzes',
      description:
          'Test your knowledge with instant feedback\nand track your progress.',
      backgroundColor: const Color(0xFFE0F7FA),
    ),
    OnboardingData(
      icon: Icons.video_library_outlined,
      title: 'Video Tutorials',
      description:
          'Watch detailed explanations and learn\nconcepts visually and easily.',
      backgroundColor: const Color(0xFFE0F7FA),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _onboardingData[_currentPage].backgroundColor,
              _onboardingData[_currentPage]
                  .backgroundColor
                  .withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _navigateToLogin(),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index], size);
                  },
                ),
              ),

              // Bottom section with indicators and button
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => _buildIndicator(index),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Next/Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACC1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _navigateToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Flexible(
            flex: 3,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.35,
                minHeight: size.height * 0.25,
              ),
              child: Icon(
                data.icon,
                size: size.height * 0.15,
                color: const Color(0xFF00ACC1).withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Flexible(
            flex: 1,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.065,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00ACC1),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Flexible(
            flex: 1,
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF00ACC1)
            : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ByteBrainLoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}
