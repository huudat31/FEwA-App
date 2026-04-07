import '../bloc/auth_cubit.dart';

class AuthController {
  final AuthCubit authCubit;

  AuthController(this.authCubit);

  void handleLogin(String email, String password) {
    if (email.isEmpty || password.isEmpty) return;
    authCubit.login(email, password);
  }

  void handleRegister(String email) {
    if (email.isEmpty) return;
    authCubit.register(email);
  }

  void handleOtpVerify(String code) {
    if (code.length < 4) return;
    authCubit.verifyOtp(code);
  }

  void handleCreatePassword(String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) return;
    if (password != confirmPassword)
      return; // Normally show error, but handled in UI logic as well
    authCubit.createPassword(password);
  }

  void handleCompleteProfile(String name, String bio) {
    if (name.isEmpty) return;
    authCubit.completeProfile(name, bio);
  }

  void handleSelectGoal(String goalId) {
    if (goalId.isEmpty) return;
    authCubit.selectGoal(goalId);
  }

  void handleLogout() {
    authCubit.logout();
  }
}
