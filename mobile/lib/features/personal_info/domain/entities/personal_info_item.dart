import 'package:flutter/material.dart';

class PersonalInfoItem {
  final String label;
  final String value;
  final String hint;
  final bool isEditable;
  final VoidCallback? onTap;

  const PersonalInfoItem({
    required this.label,
    required this.value,
    required this.hint,
    required this.isEditable,
    this.onTap,
  });
}
