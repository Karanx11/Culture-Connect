import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPasswordHidden = true;
  bool isConfirmHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BG IMAGE
          SizedBox.expand(
            child: Image.asset(
              "assets/images/auth.jpg",
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),

          Container(color: Colors.black.withOpacity(0.4)),

          /// GLASS CARD
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// TITLE
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// NAME
                        _input("Name", Icons.person),

                        const SizedBox(height: 10),

                        /// EMAIL
                        _input("Email", Icons.email),

                        const SizedBox(height: 10),

                        /// CITY
                        _input("City", Icons.location_city),

                        const SizedBox(height: 10),

                        /// PASSWORD
                        TextField(
                          obscureText: isPasswordHidden,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration(
                            "Password",
                            Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(
                                () => isPasswordHidden = !isPasswordHidden,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// CONFIRM PASSWORD
                        TextField(
                          obscureText: isConfirmHidden,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration(
                            "Confirm Password",
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                isConfirmHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(
                                () => isConfirmHidden = !isConfirmHidden,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SIGNUP BUTTON
                        _button("Create Account"),

                        const SizedBox(height: 10),

                        /// LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xffFF7900),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 INPUT FIELD
  Widget _input(String hint, IconData icon) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(hint, icon),
    );
  }

  /// 🎨 DECORATION
  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// 🔘 BUTTON
  Widget _button(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffFF7900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // TODO: Add signup logic
        },
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
