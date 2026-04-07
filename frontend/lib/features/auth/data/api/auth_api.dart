import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
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
}
