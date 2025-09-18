import 'package:flutter/material.dart';
import 'login_screen.dart'; // ✅ import your login screen
import 'home_screen.dart';

// constants
const double fontTitle = 22;
const double fontField = 16;
const double verticalSpacing = 16;
const double buttonHeight = 48;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String email = "";
  String phone = "";
  String password = "";
  String confirmPassword = "";
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully!")),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient header
          Container(
            height: size.height * 0.32,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0172AF), Color(0xFF74FEBD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 26.0, top: 25.0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // White overlay with form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.85,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Create Account",
                          style: TextStyle(
                              fontSize: fontTitle,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // name
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter name"
                                  : null,
                              onChanged: (val) => setState(() => name = val),
                              style: TextStyle(fontSize: fontField),
                            ),
                            SizedBox(height: verticalSpacing),

                            // email
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter email"
                                  : null,
                              onChanged: (val) => setState(() => email = val),
                              style: TextStyle(fontSize: fontField),
                            ),
                            SizedBox(height: verticalSpacing),

                            // phone
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Phone",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter phone"
                                  : null,
                              onChanged: (val) => setState(() => phone = val),
                              style: TextStyle(fontSize: fontField),
                            ),
                            SizedBox(height: verticalSpacing),

                            // password
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              obscureText: true,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter password"
                                  : null,
                              onChanged: (val) =>
                                  setState(() => password = val),
                              style: TextStyle(fontSize: fontField),
                            ),
                            SizedBox(height: verticalSpacing),

                            // confirm password
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              obscureText: true,
                              validator: (val) => val != password
                                  ? "Passwords do not match"
                                  : null,
                              onChanged: (val) =>
                                  setState(() => confirmPassword = val),
                              style: TextStyle(fontSize: fontField),
                            ),
                            SizedBox(height: verticalSpacing * 1.2),

                            // signup button
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F8CFF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: 6,
                                ),
                                onPressed: _loading ? null : _signup,
                                child: _loading
                                    ? SizedBox(
                                        height: buttonHeight * 0.6,
                                        width: buttonHeight * 0.6,
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Text("Sign Up",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontField)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // login navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ",
                              style: TextStyle(fontSize: 14)),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const ByteBrainLoginScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.2),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                                  begin: 0.95, end: 1.0)
                                              .animate(animation),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 350),
                                ),
                              );
                            },
                            child: const Text('Login',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      // divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('OR CONTINUE WITH',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // social login
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.apple, color: Colors.black),
                          label: const Text("Continue with Apple",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.g_mobiledata,
                              color: Color(0xFFEA4335), size: 28),
                          label: const Text("Continue with Google",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
