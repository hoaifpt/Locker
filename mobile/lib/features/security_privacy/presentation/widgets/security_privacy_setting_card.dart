import 'package:flutter/material.dart';

class SecurityPrivacySettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final Color iconBackground;

  const SecurityPrivacySettingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onChanged,
    required this.icon,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A1A1C1C),
            blurRadius: 16,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: iconBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(icon, color: const Color(0xFF1A1C1C)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1C),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF52443E),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _ToggleSwitch(isEnabled: isEnabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.isEnabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: SizedBox(
        width: 44,
        height: 24,
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 24,
              decoration: ShapeDecoration(
                gradient: isEnabled
                    ? const LinearGradient(
                        begin: Alignment(-0.89, -1.21),
                        end: Alignment(0.89, 1.21),
                        colors: [Color(0xFFFFB79D), Color(0xFFFF8E65)],
                      )
                    : null,
                color: isEnabled ? null : const Color(0xFFE4E4E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            Positioned(
              left: isEnabled ? 22 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
