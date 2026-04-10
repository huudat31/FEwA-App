abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> register(String email);
  Future<void> verifyOtp(String email, String code);
  Future<Map<String, dynamic>> createPassword(String email, String password);
  Future<void> saveProfile(String name, String bio);
  Future<void> selectGoal(String goalId);
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<Map<String, dynamic>> loginWithGoogle();
  Future<Map<String, dynamic>> loginWithFacebook();
}
