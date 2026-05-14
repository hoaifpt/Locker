import 'package:flutter/material.dart';

class PhotoConfirmationPreviewFrame extends StatelessWidget {
  final String previewImageUrl;
  final String instruction;

  const PhotoConfirmationPreviewFrame({
    super.key,
    required this.previewImageUrl,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(previewImageUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color(0x401B1C19)),
          ),
          const Positioned(
            left: 32,
            right: 32,
            top: 32,
            bottom: 90,
            child: _FrameCorners(),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.80),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF52443E),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        color: Color(0xFF52443E),
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameCorners extends StatelessWidget {
  const _FrameCorners();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(top: 0, left: 0, child: _Corner(top: true, left: true)),
        Positioned(top: 0, right: 0, child: _Corner(top: true, left: false)),
        Positioned(bottom: 0, left: 0, child: _Corner(top: false, left: true)),
        Positioned(
            bottom: 0, right: 0, child: _Corner(top: false, left: false)),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;

  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: Colors.white.withOpacity(0.85), width: 4)
              : BorderSide.none,
          bottom: !top
              ? BorderSide(color: Colors.white.withOpacity(0.85), width: 4)
              : BorderSide.none,
          left: left
              ? BorderSide(color: Colors.white.withOpacity(0.85), width: 4)
              : BorderSide.none,
          right: !left
              ? BorderSide(color: Colors.white.withOpacity(0.85), width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(48) : Radius.zero,
          topRight: top && !left ? const Radius.circular(48) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(48) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(48) : Radius.zero,
        ),
      ),
    );
  }
}
