import 'package:flutter/material.dart';

import '../../data/qr_scanner_repository.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late final Future<List<ScanResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = GetScanHistoryUsecase(QrScannerRepository())();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử quét'),
        backgroundColor: const Color(0xFF1A120E),
      ),
      body: FutureBuilder<List<ScanResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFB923C)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không tải được lịch sử quét',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            );
          }

          final scans = snapshot.data ?? const <ScanResult>[];
          if (scans.isEmpty) {
            return const Center(
              child: Text('Chưa có lịch sử quét.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemBuilder: (context, index) {
              final scan = scans[index];
              return _ScanHistoryTile(scan: scan);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: scans.length,
          );
        },
      ),
    );
  }
}

class _ScanHistoryTile extends StatelessWidget {
  final ScanResult scan;

  const _ScanHistoryTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xFFF7F5F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        scan.lockerCode ?? scan.lockerId ?? scan.qrCode,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        scan.isValid ? 'Mã hợp lệ' : 'Mã không hợp lệ',
        style: TextStyle(
          color:
              scan.isValid ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        ),
      ),
      trailing: Text(
        scan.scannedAt
            .toLocal()
            .toIso8601String()
            .substring(0, 16)
            .replaceFirst('T', ' '),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
