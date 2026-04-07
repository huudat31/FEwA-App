import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_text.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String email;
  const CreatePasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final AuthController _authController;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // User is locked into flow
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMsg =
                _localError ?? (state is AuthError ? state.message : null);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Create Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Secure your account for future logins.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF3C4A42)),
                  ),
                  const SizedBox(height: 48),
                  AppTextField(
                    controller: _passwordController,
                    hintText: 'New Password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  ErrorText(error: errorMsg),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Continue',
                    isLoading: isLoading,
                    onPressed: () {
                      setState(() => _localError = null);
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        setState(() => _localError = 'Passwords do not match');
                        return;
                      }
                      _authController.handleCreatePassword(
                        _passwordController.text,
                        _confirmPasswordController.text,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
