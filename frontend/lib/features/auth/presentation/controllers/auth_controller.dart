import '../bloc/auth_cubit.dart';

class AuthController {
  final AuthCubit authCubit;

  AuthController(this.authCubit);

  void handleLogin(String email, String password) {
    final emailError = _validateEmail(email);
    if (emailError != null) {
      authCubit.emitValidationError(emailError);
      return;
    }
    if (password.length < 6) {
      authCubit.emitValidationError('Password must be at least 6 characters');
      return;
    }
    authCubit.login(email, password);
  }

  void handleGoogleLogin() {
    authCubit.loginWithGoogle();
  }

  void handleFacebookLogin() {
    authCubit.loginWithFacebook();
  }

  void handleRegister(String fullName, String email, String password) {
    if (fullName.trim().isEmpty) {
      authCubit.emitValidationError('Full name is required');
      return;
    }
    final emailError = _validateEmail(email);
    if (emailError != null) {
      authCubit.emitValidationError(emailError);
      return;
    }
    if (password.length < 8) {
      authCubit.emitValidationError('Password must be at least 8 characters');
      return;
    }
    authCubit.register(fullName, email, password);
  }

  String? _validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email.trim())) return 'Enter a valid email address';
    return null;
  }

  void handleOtpVerify(String code) {
    if (code.length < 4) return;
    authCubit.verifyOtp(code);
  }

  void handleCreatePassword(String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) return;
    if (password != confirmPassword) return; 
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

