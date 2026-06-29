import 'package:flutter/material.dart';

class PersonalInfoFieldCard extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final bool isEditable;
  final VoidCallback? onTap;

  const PersonalInfoFieldCard({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.isEditable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF52443E),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1C),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hint.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isEditable)
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFFEE8C2B),
              ),
          ],
        ),
      ),
    );
  }
}
