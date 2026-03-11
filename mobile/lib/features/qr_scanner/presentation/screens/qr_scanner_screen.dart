import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/qr_scanner_cubit.dart';
import '../controllers/qr_scanner_state.dart';
import '../widgets/scan_progress_card.dart';
import '../widgets/scanner_bottom_bar.dart';
import '../widgets/scanner_viewfinder.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      context.read<QrScannerCubit>().onQrDetected(barcode!.rawValue!);
    }
  }

  Future<void> _showManualEntryDialog(BuildContext ctx) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.scannerSurface,
        title: const Text(
          'Nhập mã thủ công',
          style: TextStyle(color: Colors.white, fontFamily: 'Manrope'),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nhập mã QR...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.scannerAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.scannerAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: AppColors.scannerAccent),
            ),
          ),
        ],
      ),
    );
    if (code != null && code.isNotEmpty && mounted) {
      // ignore: use_build_context_synchronously
      ctx.read<QrScannerCubit>().onManualCodeEntered(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrScannerCubit, QrScannerState>(
      listener: (context, state) {
        if (state is QrScannerSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Tủ ${state.result.lockerCode ?? state.result.lockerId ?? ''} đã mở!'),
              backgroundColor: AppColors.scannerAccent,
            ),
          );
          if (state.result.lockerId != null) {
            Navigator.pushReplacementNamed(
              context,
              '/locker-detail',
              arguments: state.result.lockerId,
            );
          }
        } else if (state is QrScannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: () => context.read<QrScannerCubit>().retryScanning(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state is QrScannerProcessing;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.scannerBg,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Camera feed
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _onDetect,
                ),

                // Dark vignette overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [Colors.transparent, Color(0xB31A120E)],
                    ),
                  ),
                ),

                // Center column: viewfinder + optional progress card
                Column(
                  children: [
                    // Header space
                    const SizedBox(height: 96),
                    // Viewfinder
                    const ScannerViewfinder(),
                    const SizedBox(height: 24),
                    // Progress card (only when processing)
                    if (isProcessing)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: ScanProgressCard(
                          progress: 0.75,
                          status: 'Đang nhận diện...',
                        ),
                      ),
                    const Spacer(),
                  ],
                ),

                // Header overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _QrScannerHeader(cameraController: _cameraController),
                ),

                // Bottom bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ScannerBottomBar(
                    onGallery: () =>
                        _cameraController.analyzeImage(''), // pick from gallery
                    onCapture: () {}, // camera already continuously scans
                    onHistory: () =>
                        Navigator.pushNamed(context, '/scan-history'),
                    onManualEntry: () => _showManualEntryDialog(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _QrScannerHeader extends StatefulWidget {
  final MobileScannerController cameraController;
  const _QrScannerHeader({required this.cameraController});

  @override
  State<_QrScannerHeader> createState() => _QrScannerHeaderState();
}

class _QrScannerHeaderState extends State<_QrScannerHeader> {
  bool _torchOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC1A120E), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0x4D3E2F28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Quét mã QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Flash toggle
          GestureDetector(
            onTap: () {
              widget.cameraController.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: _torchOn
                    ? AppColors.scannerAccent.withValues(alpha: 0.3)
                    : const Color(0x4D3E2F28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? AppColors.scannerAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
