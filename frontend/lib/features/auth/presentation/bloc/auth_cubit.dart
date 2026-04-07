import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api/auth_api.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthApi api;

  // Storing intermediate email during the flow
  String? _pendingEmail;
  Map<String, dynamic>? _user;

  AuthCubit(this.api) : super(AuthInitial());

  Future<void> checkCurrentUser() async {
    emit(AuthLoading());
    try {
      _user = await api.getCurrentUser();
      if (_user != null) {
        emit(AuthAuthenticated(_user!));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email) async {
    emit(AuthLoading());
    try {
      await api.register(email);
      _pendingEmail = email;
      emit(AuthOtpSent(email));
    } catch (e) {
      emit(
        AuthError(
          'Registration Failed: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<void> verifyOtp(String code) async {
    if (_pendingEmail == null) return;

    emit(AuthVerifyingOtp(_pendingEmail!));
    try {
      await api.verifyOtp(_pendingEmail!, code);
      emit(AuthCreatingPassword(_pendingEmail!));
    } catch (e) {
      emit(
        AuthError('OTP Invalid: ${e.toString().replaceAll("Exception: ", "")}'),
      );
      emit(
        AuthOtpSent(_pendingEmail!),
      ); // Return to OTP screen state so they can re-enter
    }
  }

  Future<void> createPassword(String password) async {
    if (_pendingEmail == null) return;

    emit(AuthLoading());
    try {
      _user = await api.createPassword(_pendingEmail!, password);
      emit(AuthOnboarding(onboardingStep: 1)); // Proceed to profile setup
    } catch (e) {
      emit(
        AuthError(
          'Failed to create password: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthCreatingPassword(_pendingEmail!));
    }
  }

  Future<void> completeProfile(String name, String bio) async {
    emit(AuthLoading());
    try {
      await api.saveProfile(name, bio);
      emit(AuthOnboarding(onboardingStep: 2)); // Proceed to goal selection
    } catch (e) {
      emit(
        AuthError(
          'Failed to save profile: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthOnboarding(onboardingStep: 1));
    }
  }

  Future<void> selectGoal(String goalId) async {
    emit(AuthLoading());
    try {
      await api.selectGoal(goalId);
      if (_user != null) {
        emit(AuthAuthenticated(_user!));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(
        AuthError(
          'Failed to save goal: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthOnboarding(onboardingStep: 2));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      _user = await api.login(email, password);
      // In a real app we would check if onboarding is complete inside the _user object
      // For now, immediately move to authenticated since Login resolves to Home.
      emit(AuthAuthenticated(_user!));
    } catch (e) {
      emit(
        AuthError(
          'Failed to login: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await api.logout();
      _user = null;
      _pendingEmail = null;
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout.'));
      emit(AuthAuthenticated(_user ?? {}));
    }
  }
}
