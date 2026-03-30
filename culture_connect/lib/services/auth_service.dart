import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<void> signInWithGoogle() async {
    try {
      // Step 1: Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      // Step 2: Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ✅ IMPORTANT TOKEN
      final String idToken = googleAuth.idToken!;

      print("ID TOKEN: $idToken");

      // Step 3: Send to backend
      final response = await http.post(
        Uri.parse("http://10.169.38.31:5000/api/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": idToken,
          "name": googleUser.displayName,
          "email": googleUser.email,
        }),
      );

      print("Response: ${response.body}");
    } catch (e) {
      print("Login Error: $e");
    }
  }
}
