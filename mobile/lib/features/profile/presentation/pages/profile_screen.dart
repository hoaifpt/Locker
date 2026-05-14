import 'package:flutter/material.dart';

import '../../domain/entities/profile_info.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileScreen extends StatefulWidget {
  final GetProfileUsecase getProfile;

  const ProfileScreen({
    super.key,
    required this.getProfile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<ProfileInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text('Cài Đặt Tài Khoản'),
      ),
      body: FutureBuilder<ProfileInfo>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFB923C)));
          }

          if (!snapshot.hasData) {
            return const Center(
                child: Text('Không tải được thông tin người dùng'));
          }

          final p = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0x33EE8C2B),
                        child: Icon(Icons.person, size: 48)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.fullName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(p.email,
                            style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Text('Points: ${p.points}',
                            style: const TextStyle(
                                color: Color(0xFFEE8C2B),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildOption('Ví của tôi', 'Manage payment methods',
                    Icons.account_balance_wallet),
                const SizedBox(height: 12),
                _buildOption('Bảo mật', 'Password, FaceID', Icons.lock_outline),
                const SizedBox(height: 12),
                _buildOption('Trợ giúp', 'FAQs, Support', Icons.help_outline),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444)),
                    onPressed: () {},
                    child: const Text('Đăng xuất'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOption(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(icon, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
