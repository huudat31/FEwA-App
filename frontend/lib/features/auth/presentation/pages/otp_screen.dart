import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_text.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F9FB,
      ), // Using the Stitch primary background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191C1E)),
          onPressed: () {
            // Can context.read<AuthCubit>().logout() or go back to register depending on logic
            // For now, let's just logout to restart
            context.read<AuthCubit>().logout();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthVerifyingOtp;
            final errorMsg = state is AuthError ? state.message : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Verify Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent an OTP to ${widget.email}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3C4A42),
                    ),
                  ),
                  const SizedBox(height: 48),
                  AppTextField(
                    controller: _otpController,
                    hintText: 'Enter OTP code (e.g. 1234)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ErrorText(error: errorMsg),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Verify',
                    isLoading: isLoading,
                    onPressed: () {
                      _authController.handleOtpVerify(_otpController.text);
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
