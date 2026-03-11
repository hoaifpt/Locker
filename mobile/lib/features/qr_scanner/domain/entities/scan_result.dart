/// Kết quả sau khi quét và validate một mã QR
class ScanResult {
  final String id;
  final String qrCode; // giá trị raw quét được
  final String? lockerId; // ID tủ nếu QR hợp lệ
  final String? lockerCode; // mã tủ hiển thị (VD: "A01")
  final DateTime scannedAt;
  final bool isValid;

  const ScanResult({
    required this.id,
    required this.qrCode,
    required this.scannedAt,
    required this.isValid,
    this.lockerId,
    this.lockerCode,
  });
}
