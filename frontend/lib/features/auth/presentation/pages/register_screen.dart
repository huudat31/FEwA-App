import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_text.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    _authController.handleRegister(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191C1E)),
          onPressed: () {
            // Let AuthGate handle reversing back to Login by logging out or just swap it
            // Typically, if they are here, we can just clear cubit error state.
            // We'll use a local Navigator pop if it's pushed, but AuthGate handles it declaratively.
            context.read<AuthCubit>().logout();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMsg = state is AuthError ? state.message : null;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to get started',
                      style: TextStyle(fontSize: 15, color: Color(0xFF3C4A42)),
                    ),
                    const SizedBox(height: 48),
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    ErrorText(error: errorMsg),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Continue',
                      isLoading: isLoading,
                      onPressed: _onRegisterPressed,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthCubit>()
                            .logout(); // Resets state to Unauthenticated, Gate shows Login
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
