import 'dart:ui';
import 'package:culture_frontend/components/bottom_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;
  bool isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 🔥 LOGIN FUNCTION
  Future<void> loginUser() async {
    setState(() => isLoading = true);

    try {
      final username = usernameController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        throw "All fields are required";
      }

      final users = FirebaseFirestore.instance.collection('users');

      // 🔍 username → email
      final result = await users.where('username', isEqualTo: username).get();

      if (result.docs.isEmpty) {
        throw "User not found";
      }

      final email = result.docs.first['email'];

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔄 reload user to check verification
      await cred.user!.reload();

      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        throw "Please verify your email first";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful 🚀")));

      //Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/auth.jpg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.4)),

          Center(
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
                      const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔥 USERNAME FIELD
                      TextField(
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Username", Icons.person),
                      ),

                      const SizedBox(height: 15),

                      // 🔐 PASSWORD FIELD
                      TextField(
                        controller: passwordController,
                        obscureText: isObscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          "Password",
                          Icons.lock,
                          suffix: IconButton(
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                setState(() => isObscure = !isObscure),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔥 LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF7900),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFFFF5100),
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
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
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
}
