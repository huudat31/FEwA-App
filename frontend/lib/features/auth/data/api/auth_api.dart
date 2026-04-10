import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthApi implements AuthRepository {
  // Placeholder base URL for the real API
  static const String baseUrl = 'https://api.example.com/v1';

  // Helper method to simulate HTTP delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateDelay();
    if (email == 'error@test.com') {
      throw Exception('Invalid email or password');
    }
    return {'id': '123', 'email': email, 'token': 'mock_jwt_token_123'};
  }

  @override
  Future<void> register(String email) async {
    await _simulateDelay();
    if (email == 'error@test.com') {
      throw Exception('Email already exists');
    }
    // Succcess - expects OTP verification next
  }

  @override
  Future<void> verifyOtp(String email, String code) async {
    await _simulateDelay();
    if (code != '1234') {
      throw Exception('Invalid OTP code. Use 1234.');
    }
    // Success - expects password creation next
  }

  @override
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

  @override
  Future<void> saveProfile(String name, String bio) async {
    await _simulateDelay();
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    // Success
  }

  @override
  Future<void> selectGoal(String goalId) async {
    await _simulateDelay();
    // Success
  }

  @override
  Future<void> logout() async {
    await _simulateDelay();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // Rely on TokenService in the cubit layer or call GET /auth/me with stored token
    return null; 
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      if (googleUser == null) {
        throw Exception('Google login canceled by user');
      }

      // Getting authentication is now a synchronous getter returning GoogleSignInAuthentication
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Failed to retrieve Google ID token');
      }

      // Getting the accessToken via authorizationClient
      final authorization =
          await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase user is null after Google sign-in');
      }

      return {
        'id': user.uid,
        'email': user.email ?? '',
        'token': await user.getIdToken(),
      };
    } on FirebaseAuthException catch (e) {
      throw Exception('Google login failed: ${e.message}');
    } catch (e) {
      if (e.toString().contains('canceled')) {
        throw Exception('Google login canceled by user');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    switch (result.status) {
      case LoginStatus.success:
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Firebase user is null after Facebook sign-in');
        }
        return {
          'id': user.uid,
          'email': user.email ?? '',
          'token': await user.getIdToken(),
        };
      case LoginStatus.cancelled:
        throw Exception('Facebook login canceled by user');
      case LoginStatus.failed:
        throw Exception('Facebook login failed: ${result.message}');
      case LoginStatus.operationInProgress:
        throw Exception('A login operation is already in progress');
    }
  }
}
