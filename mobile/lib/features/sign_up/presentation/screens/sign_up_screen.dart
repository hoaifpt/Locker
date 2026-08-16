import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../controllers/sign_up_cubit.dart';
import '../controllers/sign_up_state.dart';
import '../validators/sign_up_validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Đồng bộ controllers → cubit để _submit() lấy đúng giá trị khi
    // Form pass. Phương án cũ (gọi cubit.setUsername trong onChanged)
    // vẫn hoạt động nhưng đôi lúc lag một nhịp so với rebuild.
    _usernameController.addListener(
      () => context.read<SignUpCubit>().setUsername(_usernameController.text),
    );
    _fullNameController.addListener(
      () => context.read<SignUpCubit>().setFullName(_fullNameController.text),
    );
    _emailController.addListener(
      () => context.read<SignUpCubit>().setEmail(_emailController.text),
    );
    _passwordController.addListener(
      () => context.read<SignUpCubit>().setPassword(_passwordController.text),
    );
    _phoneNumberController.addListener(
      () => context.read<SignUpCubit>()
          .setPhoneNumber(_phoneNumberController.text),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Lần đầu bấm Đăng ký: bật autovalidate để các lần sau error hiện
    // ngay khi user gõ tiếp (đỡ bắt user bấm submit mới biết sai).
    if (_autovalidate == AutovalidateMode.disabled) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    }

    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<SignUpCubit>().signUp();
      // Thành công → BlocListener bên dưới sẽ navigate về /login.
    } catch (e) {
      if (!mounted) return;
      // Repo đã ném AppException/ValidationException có message thật;
      // FriendlyError map sang tiếng Việt user-friendly.
      await context.showAlertError(e, title: 'Đăng ký thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.response != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thành công. Vui lòng kiểm tra email để xác thực.',
              ),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 24,
                children: [
                  _buildHeader(),
                  _buildInputFields(),
                  _buildSignUpButton(),
                  _buildLoginLink(),
                  _buildDivider(),
                  _buildSocialButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Image.asset('assets/ebox_logo.png', fit: BoxFit.contain),
        ),
        const Text(
          'Tạo tài khoản',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          'Tham gia E-BOX để quản lý các kiện hàng\nthông minh của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF757575), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      spacing: 16,
      children: [
        _buildTextField(
          controller: _usernameController,
          hint: 'Tên đăng nhập',
          prefixIcon: Icons.person,
          validator: SignUpValidators.username,
          textInputAction: TextInputAction.next,
        ),
        _buildTextField(
          controller: _emailController,
          hint: 'Địa chỉ Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: SignUpValidators.email,
          textInputAction: TextInputAction.next,
        ),
        _buildTextField(
          controller: _passwordController,
          hint: 'Mật khẩu (≥8 ký tự, có chữ hoa/thường/số)',
          prefixIcon: Icons.lock_outline,
          obscureText: !_showPassword,
          validator: SignUpValidators.password,
          textInputAction: TextInputAction.next,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showPassword = !_showPassword),
            child: Icon(
              _showPassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF757575),
            ),
          ),
        ),
        _buildTextField(
          controller: _confirmController,
          hint: 'Xác nhận mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: !_showConfirm,
          // Confirm phụ thuộc password hiện tại — đóng lại validator
          // mỗi lần rebuild để luôn so sánh với giá trị mới nhất.
          validator: SignUpValidators.confirm(_passwordController.text),
          textInputAction: TextInputAction.next,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showConfirm = !_showConfirm),
            child: Icon(
              _showConfirm ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF757575),
            ),
          ),
        ),
        _buildTextField(
          controller: _fullNameController,
          hint: 'Họ và tên (tùy chọn)',
          prefixIcon: Icons.person_outline,
          // Full name optional — không có validator.
          textInputAction: TextInputAction.next,
        ),
        _buildTextField(
          controller: _phoneNumberController,
          hint: 'Số điện thoại (tùy chọn)',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: SignUpValidators.phone,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required TextInputAction textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autocorrect: false,
      validator: validator,
      // Trigger confirm revalidate khi password thay đổi.
      onChanged: validator != null && controller == _passwordController
          ? (_) => _formKey.currentState?.validate()
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0x99757575)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF757575)),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF27B50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (prev, next) => prev.isLoading != next.isLoading,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    _submit();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF27B50),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0x19000000),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        const Text(
          'Đã có tài khoản?',
          style: TextStyle(color: Color(0xFF757575), fontSize: 16),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: Color(0xFFF27B50),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      spacing: 16,
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
        const Text(
          'HOẶC ĐĂNG KÝ VỚI',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        _buildSocialButton(Icons.g_translate, 'Google'),
        _buildSocialButton(Icons.facebook, 'Facebook'),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF757575)),
        onPressed: () {
          // TODO: Implement social login
        },
      ),
    );
  }
}