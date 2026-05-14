import 'package:flutter/material.dart';

class PhotoConfirmationControls extends StatelessWidget {
  final bool flashOn;
  final VoidCallback onRetake;
  final VoidCallback onCapture;
  final VoidCallback onToggleFlash;

  const PhotoConfirmationControls({
    super.key,
    required this.flashOn,
    required this.onRetake,
    required this.onCapture,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlAction(
          icon: Icons.refresh_rounded,
          label: 'CHUP LAI',
          onTap: onRetake,
        ),
        _CaptureButton(onTap: onCapture),
        _ControlAction(
          icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          label: 'BAT DEN',
          onTap: onToggleFlash,
        ),
      ],
    );
  }
}

class _ControlAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF52443E)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF52443E),
            fontSize: 10,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x33FDB69C), width: 4),
        ),
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFB59A), Color(0xFFFF8E65)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x4CFF8E65),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
