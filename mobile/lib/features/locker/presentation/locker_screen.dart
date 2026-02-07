import 'package:flutter/material.dart';
import '../data/locker_repository.dart';
import '../models/locker_model.dart';

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  final _repository = LockerRepository();
  List<LockerModel> _lockers = [];
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
      final data = await _repository.getLockers();
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

  Future<void> _openLocker(String id, String code) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await _repository.openLocker(id);

      // Hide loading
      if (mounted) Navigator.pop(context);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã mở tủ $code thành công!')));
      }

      // Refresh list
      _loadData();
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Locker"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text("Thử lại")),
          ],
        ),
      );
    }

    if (_lockers.isEmpty) {
      return const Center(child: Text("Không có tủ nào."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _lockers.length,
      itemBuilder: (context, index) {
        final locker = _lockers[index];
        return _buildLockerItem(locker);
      },
    );
  }

  Widget _buildLockerItem(LockerModel locker) {
    return Card(
      elevation: 4,
      color: locker.isOccupied ? Colors.red.shade100 : Colors.green.shade100,
      child: InkWell(
        onTap: () => _openLocker(locker.id, locker.code),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              locker.isOccupied ? Icons.lock : Icons.lock_open,
              size: 32,
              color: locker.isOccupied ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              "Tủ ${locker.code}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              locker.isOccupied ? "Đang sử dụng" : "Trống",
              style: TextStyle(
                color: locker.isOccupied ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
