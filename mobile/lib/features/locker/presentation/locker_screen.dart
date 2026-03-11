import 'package:flutter/material.dart';

import '../data/locker_repository.dart';
import '../domain/entities/locker.dart';

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  final _repository = LockerRepository();
  List<Locker> _lockers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await _repository.getAvailableLockers();
      setState(() {
        _lockers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ khả dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _lockers.isEmpty
                  ? const Center(child: Text('Không có tủ khả dụng'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lockers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final locker = _lockers[index];
                        return _LockerCard(
                          locker: locker,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/locker-detail',
                            arguments: locker.id,
                          ),
                        );
                      },
                    ),
    );
  }
}

class _LockerCard extends StatelessWidget {
  final Locker locker;
  final VoidCallback onTap;

  const _LockerCard({required this.locker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.15),
          child: Icon(Icons.inbox, color: cs.primary),
        ),
        title: Text(locker.code,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            locker.location.isEmpty ? 'Không có địa chỉ' : locker.location),
        trailing: Icon(Icons.chevron_right, color: cs.primary),
        onTap: onTap,
      ),
    );
  }
}
