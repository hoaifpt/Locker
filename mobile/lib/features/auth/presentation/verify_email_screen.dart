import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controllers/verify_email_cubit.dart';
import 'controllers/verify_email_state.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;

    return BlocListener<VerifyEmailCubit, VerifyEmailState>(
      listener: (context, state) {
        final successMessage = state.successMessage;
        if (successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
        final errorMessage = state.errorMessage;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F8F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'E-BOX',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDEFEA), // Orange-100
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFFF27B50), // Orange-500
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kiểm tra hộp thư của bạn',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chúng tôi đã gửi một liên kết xác minh đến email:\n${email ?? 'email của bạn'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context
                                  .read<VerifyEmailCubit>()
                                  .resendEmail(email);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF27B50),
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Gửi lại email xác minh',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Đã xác minh? Đăng nhập ngay',
                    style: TextStyle(
                      color: Color(0xFFF27B50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
