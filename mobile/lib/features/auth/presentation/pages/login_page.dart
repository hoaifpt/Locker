import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_cubit.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/auth_state.dart';
import '../widgets/animated_login_logo.dart';
import '../widgets/hi_tech_background.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthCubit is provided at the root by main.dart (app-wide singleton)
    // so login/logout state survives route changes.
    return const _LoginView();
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
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Client-side validation: tránh show lỗi kiểu dev (`Sai tài khoản hoặc
  /// mật khẩu`) khi user chưa nhập gì. Trả về null nếu hợp lệ, ngược lại
  /// trả về [FormField] error message.
  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập tài khoản hoặc email';
    if (v.length < 3) return 'Tài khoản phải có ít nhất 3 ký tự';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  Future<void> _submit() async {
    // Lần đầu bấm Đăng nhập: bật live validation để các lần sau error
    // hiện ngay khi user gõ — tránh bắt user bấm submit mới biết sai.
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);

    // Validate form trư�c khi gọi API — tránh round-trip vô ích.
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AuthCubit>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      await cubit.login(username, password);
      // AuthGate sẽ tự swap sang HomePage khi state thành AuthAuthenticated.
    } catch (e) {
      if (!mounted) return;
      // Exception được map qua FriendlyError → message tiếng Việt user-friendly.
      await context.showAlertError(e, title: 'Đăng nhập thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Không còn BlocListener: AuthCubit.login() giờ rethrow exception
    // thay vì emit AuthError, nên UI bắt trực tiếp qua try/catch trong
    // _submit() và hiển thị qua FriendlyError.
    return Scaffold(
        backgroundColor: const Color(0xFF1A0E08),
        body: HiTechBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  // State-driven: mặc định disabled (không hiện error trước
                  // khi user bấm submit lần đầu). Sau lần submit đầu tiên
                  // _submit() bật onUserInteraction để các lần sau error
                  // hiện ngay khi user gõ tiếp.
                  autovalidateMode: _autovalidate,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      // Logo is centered and animated (subtle pulse +
                      // glow) — see AnimatedLoginLogo.
                      const Center(
                        child: AnimatedLoginLogo(size: 200),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chào mừng đến với Ebox',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để quản lý tủ đồ thông minh của bạn',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      _InputField(
                        controller: _usernameController,
                        hint: 'Tài khoản / Email',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 14),
                      _InputField(
                        controller: _passwordController,
                        hint: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFFFB923C),
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.pushNamed('/forgot-password');
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: Color(0xFFFB923C)),
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
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chưa có tài khoản? ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed('/sign-up');
                            },
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(
                                color: Color(0xFFFB923C),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFB923C).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: const Color(0xFFFB923C).withValues(alpha: 0.18),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType ?? (obscure ? TextInputType.visiblePassword : TextInputType.text),
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        // Không đặt autovalidateMode ở field — Form cha kiểm soát.
        style: const TextStyle(color: Color(0xFF1C1C1E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFFFB923C)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          // Bỏ error border mặc định của theme để validator message hiện
          // bên dưới field (Form sẽ tự render theo InputDecorationTheme).
          errorStyle: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}