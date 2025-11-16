import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'themes/index.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/enhanced_home_screen.dart';
import 'services/auth_backend_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteBrain',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const ByteBrainLoginScreen(),
        '/home': (context) => const EnhancedHomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthBackendService.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthBackendService.getCurrentUser();
        if (user != null) {
          if (!mounted) return;
          setState(() {
            _isLoggedIn = true;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Auth check error: $e');
    }

    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ByteBrainSplashScreen();
    }

    if (_isLoggedIn) {
      return const EnhancedHomeScreen();
    }

    return const ByteBrainLoginScreen();
  }
}
