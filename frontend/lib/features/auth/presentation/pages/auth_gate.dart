import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'otp_screen.dart';
import 'create_password_screen.dart';
import 'profile_setup_screen.dart';
import 'goal_selection_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.read<AuthCubit>().logout(),
                ),
              ],
            ),
            body: Center(child: Text('Welcome, ${state.user['email']}!')),
          );
        }

        if (state is AuthOtpSent || state is AuthVerifyingOtp) {
          final email = (state is AuthOtpSent)
              ? state.email
              : (state as AuthVerifyingOtp).email;
          return OtpScreen(email: email);
        }

        if (state is AuthCreatingPassword) {
          return CreatePasswordScreen(email: state.email);
        }

        if (state is AuthOnboarding) {
          if (state.onboardingStep == 1) return const ProfileSetupScreen();
          if (state.onboardingStep == 2) return const GoalSelectionScreen();
        }

        // Unauthenticated or Error (when falling back)
        if (_showRegister) {
          return RegisterScreen(
            onToggleLogin: () {
              setState(() {
                _showRegister = false;
              });
            },
          );
        } else {
          return LoginScreen(
            onToggleRegister: () {
              setState(() {
                _showRegister = true;
              });
            },
          );
        }
      },
    );
  }
}
