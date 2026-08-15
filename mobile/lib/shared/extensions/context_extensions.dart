import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/friendly_error.dart';

extension ContextExtensions on BuildContext {
  // --- Theme shortcuts ---
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;

  // --- Size ---
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // --- SnackBar ---
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void showSnackError(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
      ));
  }

  void showSnackSuccess(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
      ));
  }

  /// Hiển thị alert dialog thân thiện — thay thế cho việc show raw
  /// exception text (kiểu "Exception: DioException [...]: ...").
  ///
  /// [error] được map qua [FriendlyError.message] để luôn trả message
  /// tiếng Việt dễ hiểu. Nếu truyền [message] string trực tiếp thì dùng
  /// luôn (đã được viết sẵn).
  Future<void> showAlert(
    String message, {
    String title = 'Thông báo',
    String confirmLabel = 'Đóng',
    AlertType type = AlertType.info,
  }) {
    return showDialog<void>(
      context: this,
      barrierDismissible: true,
      builder: (_) => _AlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        type: type,
      ),
    );
  }

  /// Alert cho lỗi — tự động convert [error] thành message thân thiện.
  Future<void> showAlertError(
    Object error, {
    String title = 'Đã xảy ra lỗi',
    String confirmLabel = 'Đã hiểu',
  }) {
    return showAlert(
      FriendlyError.message(error),
      title: title,
      confirmLabel: confirmLabel,
      type: AlertType.error,
    );
  }

  /// Dialog xác nhận — trả về true nếu user chọn "Đồng ý", false nếu
  /// chọn "Huỷ" hoặc đóng dialog.
  Future<bool> showConfirmAlert(
    String message, {
    String title = 'Xác nhận',
    String confirmLabel = 'Đồng ý',
    String cancelLabel = 'Huỷ',
    AlertType type = AlertType.warning,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      barrierDismissible: true,
      builder: (_) => _AlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        type: type,
      ),
    );
    return result ?? false;
  }

  /// Dialog hiển thị mã (order code, transaction id, …) kèm nút Copy.
  /// Tự động đưa mã vào clipboard khi user bấm "Sao chép".
  Future<void> showCopyDialog({
    required String title,
    required String code,
    String description = 'Mã đã được sao chép vào bộ nhớ tạm.',
    String? subtitle,
  }) {
    return showDialog<void>(
      context: this,
      barrierDismissible: true,
      builder: (_) => _CopyDialog(
        title: title,
        code: code,
        description: description,
        subtitle: subtitle,
      ),
    );
  }

  /// Sao chép text vào clipboard + show snack xác nhận.
  Future<void> copyToClipboard(String text, {String? label}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showSnackSuccess(label ?? 'Đã sao chép vào bộ nhớ tạm');
  }

  // --- Navigation shortcuts ---
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
  Future<T?> pushNamed<T>(String route) =>
      Navigator.of(this).pushNamed(route) as Future<T?>;
  void pushReplacementNamed(String route) =>
      Navigator.of(this).pushReplacementNamed(route);
}

enum AlertType { info, success, warning, error }

class _AlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final AlertType type;

  const _AlertDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    required this.type,
  });

  ({IconData icon, Color color, Color softBg}) get _palette {
    switch (type) {
      case AlertType.success:
        return (
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
          softBg: const Color(0xFFEFFAF3),
        );
      case AlertType.warning:
        return (
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFF59E0B),
          softBg: const Color(0xFFFFFBEB),
        );
      case AlertType.error:
        return (
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
          softBg: const Color(0xFFFEF2F2),
        );
      case AlertType.info:
        return (
          icon: Icons.info_rounded,
          color: const Color(0xFFF97316),
          softBg: const Color(0xFFFFF7ED),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: p.softBg, shape: BoxShape.circle),
              child: Icon(p.icon, color: p.color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.33,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        foregroundColor: const Color(0xFF475569),
                      ),
                      child: Text(
                        cancelLabel!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyDialog extends StatelessWidget {
  final String title;
  final String code;
  final String description;
  final String? subtitle;

  const _CopyDialog({
    required this.title,
    required this.code,
    required this.description,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFEFFAF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.33,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Code block — dùng SelectableText để user có thể bôi đen +
            // copy thủ công ngoài nút Sao chép.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (!context.mounted) return;
                  context.showSnackSuccess('Đã sao chép mã $code');
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.content_copy_rounded, size: 18),
                label: const Text(
                  'Sao chép mã',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}