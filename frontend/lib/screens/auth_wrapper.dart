import 'package:flutter/material.dart';
import '../services/auth_backend_service.dart';
import 'login_screen.dart';
import 'enhanced_home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthBackendService.isLoggedIn();
      final isAdmin = await AuthBackendService.isAdmin();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bypass authentication and open home screen directly (temporary)
    return const EnhancedHomeScreen();
  }
}
