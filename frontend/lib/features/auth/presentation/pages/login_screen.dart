import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/colors_theme.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleRegister;

  const LoginScreen({Key? key, this.onToggleRegister}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AuthController _authController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(context.read<AuthCubit>());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    _authController.handleLogin(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 238, 230),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMsg = state is AuthError ? state.message : null;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome to FLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your cognitive sanctuary for deep \nlearning and focused growth.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3C4A42),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildCard(isLoading),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(bool isLoading) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorsTheme.kCard,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 20),
          _buildFieldLabel('Email address'),
          AppTextField(
            controller: _emailController,
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildFieldLabel('Password'),
          AppTextField(
            controller: _passwordController,
            hintText: 'Password',
            isPassword: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordScreen()));
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF006C49),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AppButton(
            text: 'Login',
            isLoading: isLoading,
            onPressed: _onLoginPressed,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/svgs/google.svg', () {
                _authController.handleGoogleLogin();
              }),
              const SizedBox(width: 30),
              _buildSocialButton('assets/svgs/facebook.svg', () {
                _authController.handleFacebookLogin();
              }),
              const SizedBox(width: 30),
              _buildSocialButton('assets/svgs/apple.svg', () {}),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an account?',
                style: TextStyle(color: Color(0xFF3C4A42)),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onToggleRegister != null) {
                    widget.onToggleRegister!();
                  }
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006C49),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ColorsTheme.kLabel,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: ColorsTheme.kHint.withOpacity(.2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(children: [_buildTab(0, "Login"), _buildTab(1, "Register")]),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1 && widget.onToggleRegister != null) {
            widget.onToggleRegister!();
          } else if (index == 0) {
            setState(() {
              _selectedTab = index;
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : ColorsTheme.kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: 56,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 78, 80, 83).withOpacity(.2),
          ),
        ),
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}
