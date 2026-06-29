import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String label;
  final Function(String) onSave;
  final bool isLoading;

  const EditProfileDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.label,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.label),
            enabled: !widget.isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: widget.isLoading
              ? null
              : () => widget.onSave(_controller.text.trim()),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}
