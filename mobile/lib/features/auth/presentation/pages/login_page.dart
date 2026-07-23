import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/auth_repository.dart';
import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepository();
    return BlocProvider(
      create: (_) => AuthCubit(
        loginUsecase: LoginUsecase(repo),
        logoutUsecase: LogoutUsecase(repo),
        checkLoginUsecase: CheckLoginUsecase(repo),
        signInWithGoogleUsecase: SignInWithGoogleUsecase(repo),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.pushReplacementNamed('/home');
        } else if (state is AuthError) {
          context.showSnackError(state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFDE7DC), Color(0xFFF7D5C3)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Trợ giúp'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: const Alignment(-1.0, 0.0),
                      child: SizedBox(
                        height: 320, // Giảm chiều cao để không bị tràn
                        child: Image.asset(
                          'assets/ebox_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inbox,
                            size: 80,
                            color: Color(0xFFEB6C4B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chào mừng đến với Ebox',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C1C1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đăng nhập để quản lý tủ đồ thông minh của bạn',
                      style: TextStyle(color: Color(0xFF6C6C6C)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _InputField(
                      controller: _usernameController,
                      hint: 'Tài khoản / Email',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: _passwordController,
                      hint: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFEB6C4B),
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.pushNamed('/change-password');
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Color(0xFFEB6C4B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final loading = state is AuthLoading;
                        return AppButton(
                          label: 'Đăng nhập',
                          loading: loading,
                          onPressed: loading
                              ? null
                              : () => context.read<AuthCubit>().login(
                                  _usernameController.text.trim(),
                                  _passwordController.text,
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: Color(0xFF6C6C6C)),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed('/sign-up');
                          },
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: Color(0xFFEB6C4B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD1D1D6))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'hoặc tiếp tục với',
                            style: TextStyle(color: Color(0xFF6C6C6C)),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD1D1D6))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return ElevatedButton.icon(
                            onPressed: loading
                                ? null
                                : () => context
                                      .read<AuthCubit>()
                                      .signInWithGoogle(),
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 22,
                              width: 22,
                            ),
                            label: const Text(
                              'Đăng nhập với Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEB6C4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x18000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: obscure
            ? TextInputType.visiblePassword
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFEB6C4B)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
