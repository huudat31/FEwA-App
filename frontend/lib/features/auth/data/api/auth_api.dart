import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthApi {
  bool _isGoogleSignInInitialized = false;

  // Placeholder base URL for the real API
  static const String baseUrl = 'https://api.example.com/v1';

  // Helper method to simulate HTTP delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateDelay();
    if (email == 'error@test.com') {
      throw Exception('Invalid email or password');
    }
    return {'id': '123', 'email': email, 'token': 'mock_jwt_token_123'};
  }

  Future<void> register(String email) async {
    await _simulateDelay();
    if (email == 'error@test.com') {
      throw Exception('Email already exists');
    }
    // Succcess - expects OTP verification next
  }

  Future<void> verifyOtp(String email, String code) async {
    await _simulateDelay();
    if (code != '1234') {
      throw Exception('Invalid OTP code. Use 1234.');
    }
    // Success - expects password creation next
  }

  Future<Map<String, dynamic>> createPassword(
    String email,
    String password,
  ) async {
    await _simulateDelay();
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    return {'id': '123', 'email': email, 'token': 'mock_jwt_token_123'};
  }

  Future<void> saveProfile(String name, String bio) async {
    await _simulateDelay();
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    // Success
  }

  Future<void> selectGoal(String goalId) async {
    await _simulateDelay();
    // Success
  }

  Future<void> logout() async {
    await _simulateDelay();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    await _simulateDelay();
    return null; // By default simulate logged out structure
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
    }

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final GoogleSignInClientAuthorization? authz = await googleUser.authorizationClient.authorizationForScopes([]);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        return {'id': user.uid, 'email': user.email ?? '', 'token': await user.getIdToken()};
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('canceled')) {
        throw Exception('Google login canceled by user');
      }
      throw Exception('Google login failed: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
      
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        return {'id': user.uid, 'email': user.email ?? '', 'token': await user.getIdToken()};
      } else {
        throw Exception('Failed to sign in with Facebook');
      }
    } else {
      throw Exception(result.message ?? 'Facebook login failed');
    }
  }
}
