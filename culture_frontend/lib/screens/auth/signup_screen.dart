import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPasswordHidden = true;
  bool isConfirmHidden = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // 🔥 SIGNUP FUNCTION
  Future<void> signUpUser() async {
    setState(() => isLoading = true);

    try {
      final users = FirebaseFirestore.instance.collection('users');

      // Username check
      final existing = await users
          .where(
            'username',
            isEqualTo: usernameController.text.trim().toLowerCase(),
          )
          .get();

      if (existing.docs.isNotEmpty) {
        throw "Username already taken";
      }

      if (passwordController.text != confirmController.text) {
        throw "Passwords do not match";
      }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = cred.user!;

      // 🔥 Send verification email
      await user.sendEmailVerification();

      // Save user
      await users.doc(user.uid).set({
        'name': nameController.text.trim(),
        'username': usernameController.text.trim().toLowerCase(),
        'email': emailController.text.trim(),
        'uid': user.uid,
      });

      // ✅ POPUP (as you requested)
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Verify Email"),
          content: const Text(
            "Verification email has been sent.\nPlease check spam folder also.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
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
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
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
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _input("Name", Icons.person, nameController),

                        const SizedBox(height: 10),

                        _input(
                          "Username",
                          Icons.alternate_email,
                          usernameController,
                        ),

                        const SizedBox(height: 10),

                        _input("Email", Icons.email, emailController),

                        const SizedBox(height: 10),

                        // 🔐 PASSWORD
                        TextField(
                          controller: passwordController,
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

                        // 🔐 CONFIRM PASSWORD
                        TextField(
                          controller: confirmController,
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

                        // 🔥 SIGNUP BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signUpUser,
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
                                    "Create Account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

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

  Widget _input(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(hint, icon),
    );
  }

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
}
