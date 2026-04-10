import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/services/token_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository api;
  final TokenService tokenService;

  String? _pendingEmail;
  String? _pendingFullName;
  String? _pendingPassword;
  Map<String, dynamic>? _user;

  AuthCubit(this.api, this.tokenService) : super(AuthInitial());

  Future<void> checkCurrentUser() async {
    emit(AuthLoading());
    try {
      // First check Firebase session
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final token = await firebaseUser.getIdToken();
        _user = {'id': firebaseUser.uid, 'email': firebaseUser.email ?? '', 'token': token};
        emit(AuthAuthenticated(_user!));
        return;
      }
      // Fall back to secure storage for JWT-based auth
      _user = await tokenService.getUser();
      if (_user != null) {
        emit(AuthAuthenticated(_user!));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  void emitValidationError(String message) {
    emit(AuthError(message));
  }

  void cancelOtp() {
    _pendingEmail = null;
    _pendingFullName = null;
    _pendingPassword = null;
    emit(AuthUnauthenticated());
  }

  Future<void> register(String fullName, String email, String password) async {
    emit(AuthLoading());
    try {
      await api.register(email);
      _pendingEmail = email;
      _pendingFullName = fullName;
      _pendingPassword = password;
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
    if (_pendingEmail == null) {
      emit(AuthError('Session expired. Please register again.'));
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthVerifyingOtp(_pendingEmail!));
    try {
      await api.verifyOtp(_pendingEmail!, code);

      if (_pendingPassword == null || _pendingFullName == null) {
        // Guard: should never happen in normal flow
        emit(AuthError('Registration session lost. Please start again.'));
        emit(AuthUnauthenticated());
        return;
      }

      _user = await api.createPassword(_pendingEmail!, _pendingPassword!);
      await api.saveProfile(_pendingFullName!, '');
      await tokenService.saveUser(_user!);

      emit(AuthOnboarding(onboardingStep: 2));
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
      // await tokenService.saveUser(_user!); // Should save here if needed
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
      
      _pendingEmail = null;
      _pendingFullName = null;
      _pendingPassword = null;

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

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      _user = await api.loginWithGoogle();
      await tokenService.saveUser(_user!);
      emit(AuthAuthenticated(_user!));
    } catch (e) {
      emit(
        AuthError(
          'Failed to login with Google: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithFacebook() async {
    emit(AuthLoading());
    try {
      _user = await api.loginWithFacebook();
      await tokenService.saveUser(_user!);
      emit(AuthAuthenticated(_user!));
    } catch (e) {
      emit(
        AuthError(
          'Failed to login with Facebook: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      _user = await api.login(email, password);
      await tokenService.saveUser(_user!);
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
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
      await tokenService.clearUser();

      _user = null;
      _pendingEmail = null;
      _pendingFullName = null;
      _pendingPassword = null;
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout.'));
      emit(AuthAuthenticated(_user ?? {}));
    }
  }
}
