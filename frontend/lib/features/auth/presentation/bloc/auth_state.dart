abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  AuthOtpSent(this.email);
}

class AuthVerifyingOtp extends AuthState {
  final String email;
  AuthVerifyingOtp(this.email);
}

class AuthCreatingPassword extends AuthState {
  final String email;
  AuthCreatingPassword(this.email);
}

class AuthOnboarding extends AuthState {
  // Step 1: Profile setup, Step 2: Goal Selection
  final int onboardingStep;
  AuthOnboarding({this.onboardingStep = 1});
}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
